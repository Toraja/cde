use clap::Parser;
use std::path::PathBuf;

#[derive(Parser, Debug)]
#[command(version)]
#[command(about = "Download an asset of the latest release from github")]
pub struct Args {
    /// User/Name of the github repository such as `rust-lang/rust`.
    #[arg(value_parser = parse_non_blank_string)]
    pub repository: String,

    /// Name of the asset (file) in the release.
    #[arg(value_parser = parse_non_blank_string)]
    pub asset_name: String,

    /// Path to which the downloaded asset is placed.
    pub destination: PathBuf,

    /// Verify the downloaded file with the checksum if provided.
    #[arg(short = 'c', long, value_parser = parse_non_blank_string)]
    pub checksum: Option<String>,

    /// Extract tarball (.tar.gz) into the destination (must be a directory).
    #[arg(
        short = 't',
        long,
        default_value_ifs([
            ("untar_member", clap::builder::ArgPredicate::IsPresent, Some("true")),
            ("strip_components", clap::builder::ArgPredicate::IsPresent, Some("true")),
        ])
    )]
    pub untar: bool,

    /// Extract only the selected file in the tarball into the destination (must be a directory).
    #[arg(short = 'T', long, value_parser = parse_non_blank_string, value_delimiter = ',')]
    pub untar_member: Vec<String>,

    /// Value is passed to tar's `--strip-components` option. This implies `untar`.
    #[arg(short, long)]
    pub strip_components: Option<u32>,

    /// Make specified downloaded files executable. The value must be relative path from the destination.
    #[arg(short = 'x', long, value_parser = parse_non_blank_string, value_delimiter = ',')]
    pub executable_files: Vec<String>,
}

fn parse_non_blank_string(s: &str) -> Result<String, String> {
    if s.trim().is_empty() {
        return Err("it must be non empty, non white space characters".into());
    }

    Ok(s.into())
}

#[cfg(test)]
mod tests {
    use super::*;
    use rstest::rstest;
    // use std::error::Error;

    #[rstest]
    #[case(vec!["--executable-files", "a/b,c/d", "--executable-files", "e/f"], vec!("a/b", "c/d", "e/f"))]
    fn csv_for_executable_files_should_be_split_into_vector(
        #[case] flags: Vec<&str>,
        #[case] expected: Vec<&str>,
    ) {
        let mut args = vec!["cmd", "repo", "asset", "dest"];
        args.extend(flags);
        let actual = Args::try_parse_from(args).unwrap();
        assert_eq!(actual.executable_files, expected)
    }

    #[rstest]
    #[case(vec!["--untar-member", "a/b,c/d"], vec!["a/b", "c/d"])]
    fn untar_should_be_true_if_associated_flags_are_specified(
        #[case] flags: Vec<&str>,
        #[case] expected: Vec<&str>,
    ) {
        let mut args = vec!["cmd", "repo", "asset", "dest"];
        args.extend(flags);
        let actual = Args::try_parse_from(args).unwrap();
        assert!(actual.untar);
        assert_eq!(actual.untar_member, expected)
    }

    #[rstest]
    #[case(vec!["--strip-components", "3"], 3)]
    fn untar_should_be_true_if_associated_flags_are_specified_xxx(
        #[case] flags: Vec<&str>,
        #[case] expected: u32,
    ) {
        let mut args = vec!["cmd", "repo", "asset", "dest"];
        args.extend(flags);
        let actual = Args::try_parse_from(args).unwrap();
        assert!(actual.untar);
        assert_eq!(actual.strip_components, Some(expected))
    }

    #[rstest]
    #[case(vec!["cmd", "", "asset", "dest"])]
    #[case(vec!["cmd", "  ", "asset", "dest"])]
    #[case(vec!["cmd", "repo", "", "dest"])]
    #[case(vec!["cmd", "repo", "  ", "dest"])]
    #[case(vec!["cmd", "repo", "asset", ""])]
    // #[case(vec!["cmd", "repo", "asset", "  "])] // PathBuf allows white spaces
    fn it_should_be_error_if_any_of_positional_arguments_is_blank(#[case] args: Vec<&str>) {
        Args::try_parse_from(args).unwrap_err();
    }

    #[rstest]
    #[case(vec!["--checksum", ""])]
    #[case(vec!["--checksum", "   "])]
    fn it_should_be_error_if_checksum_is_blank(#[case] flags: Vec<&str>) {
        let mut args = vec!["cmd", "repo", "asset", "dest"];
        args.extend(flags);
        Args::try_parse_from(args).unwrap_err();
    }

    #[rstest]
    #[case(vec!["--untar-member", "one", "--untar-member", ""])]
    #[case(vec!["--untar-member", "   ", "--untar-member", "two"])]
    fn it_should_be_error_if_untar_member_contains_is_empty_string(#[case] flags: Vec<&str>) {
        let mut args = vec!["cmd", "repo", "asset", "dest"];
        args.extend(flags);
        Args::try_parse_from(args).unwrap_err();
    }
}
