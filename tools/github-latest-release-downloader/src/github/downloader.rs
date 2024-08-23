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
#[cfg_attr(test, derive(Default))]
pub struct GitHubAssetDownloader {
    repository: String,
    asset_name: String,
    destination: PathBuf,
    checksum: Option<String>,
    untar: bool,
    untar_member: Vec<String>,
    strip_components: Option<u32>,
    executable: bool,
}

#[allow(clippy::too_many_arguments)]
impl GitHubAssetDownloader {
    pub fn new(
        repository: String,
        asset_name: String,
        destination: PathBuf,
        checksum: Option<String>,
        untar: bool,
        untar_member: Vec<String>,
        strip_components: Option<u32>,
        executable: bool,
    ) -> Self {
        Self {
            repository,
            asset_name,
            destination,
            checksum,
            untar,
            executable,
            untar_member,
            strip_components,
        }
    }

    pub fn download_asset(&self) -> Result<(), Box<dyn Error>> {
        let asset_url = self.get_latest_release_download_url()?;

        let tmp = self.fetch_asset(&asset_url)?;

        if self.checksum.is_some() {
            self.verify_checksum(&tmp)?
        }

        if self.executable {
            self.set_executable(&tmp)?;
            self.copy_to_dest(&tmp)?;
            return Ok(());
        } else if self.untar {
            // ref: https://rust-lang-nursery.github.io/rust-cookbook/compression/tar.html
        }

        Ok(())
    }

    fn get_latest_release_download_url(&self) -> Result<String, Box<dyn Error>> {
        let url = format!(
            "https://api.github.com/repos/{}/releases/latest",
            &self.repository
        );

        let resp = Client::new()
            .get(url)
            .header(USER_AGENT, "reqwest") // github API requires USER-AGENT header
            .send()?;
        if !resp.status().is_success() {
            return Err(anyhow!(resp.text()?).into());
        }

        let github_release: Release = resp.json()?;

        Ok(github_release
            .assets
            .iter()
            .find(|asset| asset.name == self.asset_name)
            // TODO: return error instead of panic
            .unwrap_or_else(|| panic!("asset {} was not found", &self.asset_name))
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
        let provided_checksum = self
            .checksum
            .clone()
            .ok_or(anyhow!("checksum was not provided"))?;

        file.seek(io::SeekFrom::Start(0)).unwrap();

        let mut hasher = Sha256::new();
        let _ = io::copy(&mut file, &mut hasher)?;
        let hash = format!("{:x}", hasher.finalize());
        if hash != provided_checksum {
            return Err(anyhow!("checksum did not match").into());
        }

        Ok(())
    }

    fn copy_to_dest(&self, mut file: &fs::File) -> Result<(), Box<dyn Error>> {
        let _ = file.seek(io::SeekFrom::Start(0))?;

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

    fn set_executable(&self, file: &fs::File) -> Result<(), Box<dyn Error>> {
        file.set_permissions(Permissions::from_mode(0o755))?;
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use std::str::FromStr;

    use super::*;

    #[cfg(test)]
    mod get_latest_release_download_url {
        use super::*;

        #[test]
        #[ignore] // this is for demonstration purpose as github has rate limit and latest URL changes overtime
        fn it_should_return_latest_release_download_url() {
            let ghad = GitHubAssetDownloader::default()
                .with_repository("google/yamlfmt")
                .with_asset_name("yamlfmt_0.13.0_Linux_x86_64.tar.gz");
            let url = ghad.get_latest_release_download_url().unwrap();
            assert_eq!(url, "https://github.com/google/yamlfmt/releases/download/v0.13.0/yamlfmt_0.13.0_Linux_x86_64.tar.gz");
        }
    }

    #[cfg(test)]
    mod fetch_asset {
        use super::*;

        #[test]
        #[ignore] // this is for demonstration purpose as github has rate limit
        fn it_should_fetch_asset() {
            const URL: &str = "https://github.com/google/yamlfmt/releases/download/v0.10.0/yamlfmt_0.10.0_Linux_x86_64.tar.gz";
            let ghad = GitHubAssetDownloader::default();
            let asset = ghad.fetch_asset(URL).unwrap();
            assert_eq!(asset.metadata().unwrap().len(), 1370313)
            // TODO: verify checksum? (ed00383ef0dd9a97323d6ccfda3c53ed80942d33e728842ad03f22d7d0744d32)
        }
    }

    #[cfg(test)]
    mod verify_checksum {
        use super::*;

        #[test]
        fn it_should_return_ok() {
            const CHECKSUM: &str =
                "b493d48364afe44d11c0165cf470a4164d1e2609911ef998be868d46ade3de4e"; // banana
            let ghad = GitHubAssetDownloader::default().with_checksum(CHECKSUM);
            let mut tmp = tempfile::tempfile().unwrap();
            tmp.write_all(b"banana").unwrap();
            ghad.verify_checksum(&tmp).unwrap();
        }
    }

    #[cfg(test)]
    mod copy_to_dest {
        use super::*;
        use scopeguard;

        #[test]
        fn it_should_return_ok() {
            let dest = "tmplex/applepie";
            let content = "coconut";
            let mut tmp = tempfile::tempfile().unwrap();
            tmp.write_all(content.as_bytes()).unwrap();

            let ghad = GitHubAssetDownloader::default().with_destination(dest);
            ghad.copy_to_dest(&tmp).unwrap();

            scopeguard::defer! {
                fs::remove_file(dest).unwrap_or_else(|_| panic!("Failed to delete {}", dest))
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
            let f = tempfile::tempfile().unwrap();
            let ghad = GitHubAssetDownloader::default();
            ghad.set_executable(&f).unwrap();
            let permissions = f.metadata().unwrap().permissions();
            assert_eq!(permissions.mode(), 0o100755);
        }
    }

    #[allow(dead_code)]
    impl GitHubAssetDownloader {
        fn with_repository(self, repository: &str) -> GitHubAssetDownloader {
            // let repository = repository.to_string();
            // GitHubAssetDownloader { repository, ..self }
            let mut x = self;
            x.repository = repository.to_string();
            x
        }

        fn with_asset_name(self, asset_name: &str) -> GitHubAssetDownloader {
            let mut x = self;
            x.asset_name = asset_name.to_string();
            x
        }

        fn with_destination(self, destination: &str) -> GitHubAssetDownloader {
            let mut x = self;
            x.destination = PathBuf::from_str(destination).unwrap();
            x
        }

        fn with_checksum(self, checksum: &str) -> GitHubAssetDownloader {
            let mut x = self;
            x.checksum = Some(checksum.to_string());
            x
        }

        fn with_executable(self, executable: bool) -> GitHubAssetDownloader {
            let mut x = self;
            x.executable = executable;
            x
        }
    }
}
