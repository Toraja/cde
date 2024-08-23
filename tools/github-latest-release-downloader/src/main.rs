use clap::Parser;
use github_latest_release_downloader::cli::Args;
use github_latest_release_downloader::github::GitHubAssetDownloader;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    // let args = match Args::try_parse_from(std::env::args()) {
    //     Ok(args) => args,
    //     Err(e) => e.exit(),
    // };
    let args = Args::parse();

    println!("{:?}", args);
    println!("{:?}", args.destination.parent());

    let _ghad = GitHubAssetDownloader::new(
        args.repository,
        args.asset_name,
        args.destination,
        args.checksum,
        args.untar,
        args.untar_member,
        args.strip_components,
        false,
        // args.executable_files,
    );

    Ok(())
}
