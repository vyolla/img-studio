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
}

variable "api_key" {
  description = "Firebase API Key"
  type        = string
}

variable "max_token" {
  description = ""
  type        = number
  default     = 8192
}

variable "temperature" {
  description = ""
  type        = number
  default     = 0.1
}

variable "top_p" {
  description = ""
  type        = number
  default     = 1
}

variable "model_name" {
  description = ""
  type        = string
  default     = "gemini-2.0-flash-001"
}

variable "sa_email" {
  type        = string
}

variable "artifact_repo_name" {
  type        = string 
}