use clap::Parser;
use github_latest_release_downloader::cli::Args;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let flag = match Args::try_parse_from(std::env::args()) {
        Ok(flag) => flag,
        Err(e) => e.exit(),
    };

    println!("{:?}", flag);
    println!("{:?}", flag.destination.parent());
    Ok(())
}

// TODO
// - [x] get positional arguments
// - [ ] get download URL
// - [ ] download file
// - [ ] extract if specified
