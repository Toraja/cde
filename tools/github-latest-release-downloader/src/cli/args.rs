use clap::Parser;
use std::path::PathBuf;

// TODO handle mutually exclusive options
// possible to implement something like post hook? (setting untar = true when strip_components is
// specified)
#[derive(Parser, Debug)]
#[command(version)]
#[command(about = "Download an asset of the latest release from github")]
pub struct Args {
    /// User/Organisation name of the github repository.
    pub owner: String,

    /// Name of the github repository.
    pub repository: String,

    /// Name of the asset (file) in the release.
    pub asset_name: String,

    /// Path to which the downloaded file is placed.
    pub destination: PathBuf,

    /// Value is passed to tar's `--strip-components` option. This implies `untar`.
    #[arg(short, long)]
    pub strip_components: Option<u32>,

    /// Extract tarball (.tar.gz) into the destination. Mutually exclusive with -x.
    #[arg(short = 't', long)]
    pub untar: bool,

    // TODO `--untar-member aaa bbb` will store both `aaa` and `bbb` into this.
    // It should be `--untar-member aaa --untar-member bbb` for the above behavior.
    /// Extract only the selected file in the tarball into the destination. Mutually exclusive with -x.
    #[arg(short = 'T', long, value_parser, num_args = 1..)]
    pub untar_member: Vec<String>,

    /// Make downloaded file executable. Mutually exclusive with -t/T.
    #[arg(short = 'x', long)]
    pub extract: bool,

    /// Verify the downloaded file with the checksum if provided.
    #[arg(short = 'c', long)]
    pub checksum: Option<String>,
}
