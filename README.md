# Infrastructure setup guide for ImgStudio

## 0\\ Request access to **required models**

- **Imagen Models**

  - **Children (minors) generation**: contact your commercial team to ask for access
  - **Imagen 4** Generation
    - **Public Preview:** `imagen-4.0-generate-preview-05-20` (Standard)
    - **Public Experimental Preview:** `imagen-4.0-ultra-generate-exp-05-20` (Ultra)
  - **Imagen 3** Generation
    - **Public GA:** `imagen-3.0-generate-002` (Standard)
    - **Public GA:** `imagen-3.0-fast-generate-001` (Fast)
  - **Imagen 3** Editing & Customization
    - **Private GA:** `imagen-3.0-capability-001` (Standard) \- to gain access, fill out [this form](https://docs.google.com/forms/d/e/1FAIpQLScN9KOtbuwnEh6pV7xjxib5up5kG_uPqnBtJ8GcubZ6M3i5Cw/viewform)
  - **Image Segmentation model** (required for image editing in app)
    - **Private GA:** `image-segmentation-001` (Standard) \- to gain access, fill out [this form](https://docs.google.com/forms/d/e/1FAIpQLSdzIR1EeQGFcMsqd9nPip5e9ovDKSjfWRd58QVjo1zLpfdvEg/viewform?resourcekey=0-Pvqc66u-0Z1QmuzHq4wLKg&pli=1)

- **Veo Models**
  - **Veo 2** Generation (Text to Video, Image to Video)
    - **Public GA:** `veo-2.0-generate-001` (Standard)
  - **Veo 2** Advanced features (Interpolation, Camera Preset Controls, Video Extend), & **Veo 3** Generation (Text to Video \+ Audio, Image to Video \+ Audio)
    - **Private GA:** `veo-2.0-generate-exp` & `veo-3.0-generate-preview` \- to gain access, fill out [this form](https://docs.google.com/forms/d/e/1FAIpQLSciY6O_qGg2J0A8VUcK4egJ3_Tysh-wGTl-l218XtC0e7lM_w/viewform)

## 1\\ Open the **GitHub** repository in **Cloud Shell**

<a href="https://shell.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/vyolla/img-studio"><img src="http://gstatic.com/cloudssh/images/open-btn.svg" alt="Open in
Cloud Shell"></a>

## 2\\ Make the setup.sh executable

- `chmod +x setup.sh`

## 3\\ Run the setup

- `./setup.sh YOUR-PROJECT-ID`

## 4\\ Configure Firebase Authentication
- Go to Cloud Run service and copy the service URL
- Go to https://console.firebase.google.com/
- Navigate to Authentication
- Activate Email/Password and Google Providers
- Insert the users. The password is not relevant here, we will use the Google provider to login
- On the tab menu, go to Settings 
  - In Authorized Domains, add the URL of the service
  - In User Actions, unmark Enable Create

## 5\\ Access the ImgStudio
- Access the URL from Cloud Run


> ###### _This is not an officially supported Google product. This project is not eligible for the [Google Open Source Software Vulnerability Rewards Program](https://bughunters.google.com/open-source-security)._
