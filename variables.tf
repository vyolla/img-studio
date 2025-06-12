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

# Jump Start Solution variables.
variable "project_id" {
  description = "The Google Cloud project ID to deploy to"
  type        = string
  validation {
    condition     = var.project_id != ""
    error_message = "Error: project_id is required."
  }
}

variable "region" {
  description = "The Google Cloud region to deploy to"
  type        = string
  default     = "us-central1"
}


variable "deploy_modules" {
  description = "Controla quais módulos serão implantados. Mude para 'false' para desativar."
  type        = map(bool)
  default = {
    "img-studio"      = true
  }
}
