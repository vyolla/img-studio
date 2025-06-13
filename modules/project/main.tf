/**
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

module "project_services" {
  source                      = "terraform-google-modules/project-factory/google//modules/project_services"
  version                     = "~> 18.0"
  disable_services_on_destroy = var.disable_services_on_destroy

  project_id = var.project_id

  activate_apis = [
    "apikeys.googleapis.com",
    "aiplatform.googleapis.com",
    "artifactregistry.googleapis.com",
    "bigquery.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "config.googleapis.com",
    "iam.googleapis.com",
    "run.googleapis.com",
    "serviceusage.googleapis.com",
    "storage-api.googleapis.com",
    "storage.googleapis.com",
    "firebase.googleapis.com",
    "identitytoolkit.googleapis.com",
  ]
}

locals {
  sa_name    = "img-studio-sa"
  tf_state_bucket_name   = "tf-state-${var.project_id}" 
  artifact_repo_name = "img-studio-repo"
}

resource "google_storage_bucket" "tf_state_bucket" {
  project                     = var.project_id
  name                        = local.tf_state_bucket_name
  location                    = var.region
  force_destroy               = true
  uniform_bucket_level_access = true
  depends_on = [
    module.project_services
  ]
}

resource "google_artifact_registry_repository" "images" {
  project       = var.project_id
  location      = var.region
  repository_id = local.artifact_repo_name
  format        = "DOCKER"
  depends_on = [
    module.project_services
  ]
}

resource "google_project_iam_member" "img-studio-sa" {
  project = var.project_id
  member  = google_service_account.img-studio-sa.member
  for_each = toset([
    "roles/aiplatform.serviceAgent", 
    "roles/aiplatform.user",      
    "roles/storage.objectViewer",     
    "roles/artifactregistry.writer",
    "roles/artifactregistry.reader",
    "roles/logging.logWriter",
    "roles/ml.serviceAgent",
  ])
  role = each.key

  depends_on = [
    module.project_services
  ]
}

resource "google_service_account" "img-studio-sa" {
  project      = var.project_id
  account_id   = local.sa_name
  display_name = "IA Packaged Solution SA"

  depends_on = [
    module.project_services
  ]
}

resource "google_project_iam_member" "gce_account" {
  project = var.project_id
  member  = "serviceAccount:${data.google_compute_default_service_account.default.email}"
  for_each = toset([
    "roles/storage.objectAdmin",
    "roles/logging.logWriter",
    "roles/artifactregistry.createOnPushWriter",
  ])
  role = each.key
  depends_on = [
    data.google_compute_default_service_account.default
  ]
}

data "google_compute_default_service_account" "default" {
  project = var.project_id
  depends_on = [
    module.project_services
  ]
}

resource "google_firebase_project" "auth" {
  provider = google-beta
  project  = module.project_services.project_id
  depends_on = [
    module.project_services
  ]
}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [module.project_services]

  create_duration = "30s"
}

module "org-policy" {
  source            = "terraform-google-modules/org-policy/google"
  version           = "~> 5.4.0"

  policy_for        = "project"
  project_id = var.project_id
  constraint        = "constraints/iam.allowedPolicyMemberDomains"
  policy_type       = "list"
  enforce           = false

  depends_on = [
    time_sleep.wait_30_seconds
  ]
}

# resource "google_identity_platform_config" "auth" {
#   provider = google-beta
#   project  = module.project_services.project_id

#   # For example, you can configure to auto-delete anonymous users.
#   autodelete_anonymous_users = true

#   # Wait for identitytoolkit.googleapis.com to be enabled before initializing Authentication.
#   depends_on = [
#     google_firebase_project.auth,
#   ]
# }

data "external" "api_key" {
  program = ["bash", "${path.module}/firebase_api_key.sh"]

  depends_on = [
    google_firebase_project.auth,
  ]
}
