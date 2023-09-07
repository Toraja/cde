use anyhow::anyhow;
use reqwest::{blocking::Client, header::USER_AGENT};
use serde::Deserialize;
use sha2::{Digest, Sha256};
use std::{
    error::Error,
    fs::{self, Permissions},
    io::{self, prelude::*},
    os::unix::fs::PermissionsExt,
    path::PathBuf,
};

#[derive(Deserialize, Debug)]
struct Release {
    assets: Vec<Asset>,
}

#[derive(Deserialize, Debug)]
struct Asset {
    name: String,
    browser_download_url: String,
}

#[derive(Debug)]
pub struct GitHubAssetRetriever {
    owner: String,
    repository: String,
    asset_name: String,
    checksum: String,
    destination: PathBuf,
}

impl GitHubAssetRetriever {
    pub fn new(
        owner: String,
        repository: String,
        asset_name: String,
        checksum: String,
        destination: PathBuf,
    ) -> Self {
        Self {
            owner,
            repository,
            asset_name,
            checksum,
            destination,
        }
    }

    pub fn download_asset(&self) -> Result<(), Box<dyn Error>> {
        let asset_url = self.get_latest_release_download_url()?;

        let tmp = self.fetch_asset(&asset_url)?;

        // TODO only when provided
        self.verify_checksum(&tmp)?;

        self.copy_to_dest(&tmp)?;

        // TODO only when requested
        self.set_executable()?;

        Ok(())
    }

    fn get_latest_release_download_url(&self) -> Result<String, Box<dyn Error>> {
        let url = format!(
            "https://api.github.com/repos/{}/{}/releases/latest",
            &self.owner, &self.repository
        );

        let resp = Client::new()
            .get(&url)
            .header(USER_AGENT, "reqwest") // github API requires USER-AGENT header
            .send()?;
        if !resp.status().is_success() {
            return Err(anyhow!(resp.text()?).into());
        }

        let github_release: Release = resp.json()?;

        Ok(github_release
            .assets
            .iter()
            .find(|asset| &asset.name == &self.asset_name)
            .expect(format!("asset {} was not found", &self.asset_name).as_str())
            .browser_download_url
            .clone())
    }

    fn fetch_asset(&self, asset_url: &str) -> Result<fs::File, Box<dyn Error>> {
        let mut resp = Client::new().get(asset_url).send()?;
        if !resp.status().is_success() {
            return Err(anyhow!(resp.text()?).into());
        }

        let mut tmp = tempfile::tempfile()?;
        let _ = resp.copy_to(&mut tmp)?;

        Ok(tmp)
    }

    fn verify_checksum(&self, mut file: &fs::File) -> Result<(), Box<dyn Error>> {
        file.seek(io::SeekFrom::Start(0)).unwrap();

        let mut hasher = Sha256::new();
        let _ = io::copy(&mut file, &mut hasher)?;
        let hash = format!("{:x}", hasher.finalize());
        if &hash != &self.checksum {
            return Err(anyhow!("checksum did not match").into());
        }

        Ok(())
    }

    fn copy_to_dest(&self, mut file: &fs::File) -> Result<(), Box<dyn Error>> {
        file.seek(io::SeekFrom::Start(0)).unwrap();

        if self.destination.try_exists()? {
            return Err(anyhow!("Destination {:?} already exists", &self.destination).into());
        }

        if let Some(dest_dir) = self.destination.parent() {
            fs::create_dir_all(dest_dir)?
        }

        let mut dest = fs::File::create(&self.destination)?;
        let _ = io::copy(&mut file, &mut dest)?;
        Ok(())
    }

    fn set_executable(&self) -> Result<(), Box<dyn Error>> {
        let file = fs::File::open(&self.destination)?;
        Ok(file.set_permissions(Permissions::from_mode(0o755))?)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[cfg(test)]
    mod get_latest_release_download_url {
        use super::*;

        #[test]
        #[ignore] // this is for demonstration purpose as github has rate limit
        fn it_should_return_latest_release_download_url() {
            let ghar = GitHubAssetRetriever::new(
                "google".into(),
                "yamlfmt".into(),
                "yamlfmt_0.10.0_Linux_x86_64.tar.gz".into(),
                "".into(),
                "".into(),
            );
            let url = ghar.get_latest_release_download_url().unwrap();
            assert_eq!(url, "https://github.com/google/yamlfmt/releases/download/v0.10.0/yamlfmt_0.10.0_Linux_x86_64.tar.gz");
        }
    }

    #[cfg(test)]
    mod fetch_asset {
        use super::*;

        #[test]
        #[ignore] // this is for demonstration purpose as github has rate limit
        fn it_should_fetch_asset() {
            const URL: &str = "https://github.com/google/yamlfmt/releases/download/v0.10.0/yamlfmt_0.10.0_Linux_x86_64.tar.gz";
            let ghar =
                GitHubAssetRetriever::new("".into(), "".into(), "".into(), "".into(), "".into());
            let asset = ghar.fetch_asset(URL).unwrap();
            assert_eq!(asset.metadata().unwrap().len(), 1255178)
            // checksum: ed00383ef0dd9a97323d6ccfda3c53ed80942d33e728842ad03f22d7d0744d32
        }
    }

    #[cfg(test)]
    mod verify_checksum {
        use super::*;

        #[test]
        fn it_should_return_ok() {
            const CHECKSUM: &str =
                "b493d48364afe44d11c0165cf470a4164d1e2609911ef998be868d46ade3de4e"; // banana
            let ghar = GitHubAssetRetriever::new(
                "".into(),
                "".into(),
                "".into(),
                CHECKSUM.into(),
                "".into(),
            );
            let mut tmp = tempfile::tempfile().unwrap();
            tmp.write_all(b"banana").unwrap();
            ghar.verify_checksum(&tmp).unwrap();
        }
    }

    #[cfg(test)]
    mod copy_to_dest {
        use super::*;
        use scopeguard;

        #[test]
        #[ignore] // this creates files
        fn it_should_return_ok() {
            let dest = "tmplex/applepie";
            let content = "coconut";
            let mut tmp = tempfile::tempfile().unwrap();
            tmp.write_all(content.as_bytes()).unwrap();

            let ghar =
                GitHubAssetRetriever::new("".into(), "".into(), "".into(), "".into(), dest.into());
            ghar.copy_to_dest(&tmp).unwrap();

            scopeguard::defer! {
                fs::remove_file(dest).expect(&format!("Failed to delete {}", dest))
            }
            let result = fs::read_to_string(dest).unwrap();
            assert_eq!(result, content);
        }
    }

    #[cfg(test)]
    mod set_executable {
        use super::*;

        #[test]
        fn it_should_return_ok() {
            let f = tempfile::NamedTempFile::new().unwrap();
            let ghar = GitHubAssetRetriever::new(
                "".into(),
                "".into(),
                "".into(),
                "".into(),
                f.path().into(),
            );
            ghar.set_executable().unwrap();
            let permissions = f.as_file().metadata().unwrap().permissions();
            assert_eq!(permissions.mode(), 0o100755);
        }
    }
}
