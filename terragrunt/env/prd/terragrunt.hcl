remote_state {
  backend = "s3"
  config = {
    bucket = "terragrunt-sample-tfstate"
    key    = "${path_relative_to_include()}/terraform.tfstate"
    region = "ap-northeast-1"
    dynamodb_table = "terragrunt-sample-lock-table"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents = <<EOF
terraform {
  required_version = "1.7.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.33.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      Env       = "dev"
      App       = "sample-code"
      CreatedBy = "居石峻寛"
      ManagedBy = "terraform"
    }
  }
}
EOF
}

terraform {
  # planとapplyの直前にPRD環境であることをチェックする
  before_hook "before_hook" {
    commands     = ["apply", "plan"]
    execute      = ["${get_parent_tterragrunt_dir()}/confirm_env.sh"]
  }
}
