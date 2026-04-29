# mówie terraformowi, z jakiej chmury korzystam
provider "aws" {
    region = "eu-central-1" # to region Frankfurt (najblizej Polski działa najszybciej)
}

# przepis na magazyn zdjęc
resource "aws_s3_bucket" "magazyn_zdjec" {
    # nazwa bucketa musi byc unikalna na całym świecie
    bucket = "naspontanie-assets-projekt"
}