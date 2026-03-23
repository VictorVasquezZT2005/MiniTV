# MiniTV for Roku

**MiniTV** is a specialized streaming application designed for the Roku OS. Unlike standard web or mobile apps, this project leverages the unique **SceneGraph** architecture to ensure high performance and low memory consumption on hardware-constrained TV devices.

---

## Core Architecture

The application is built on two fundamental pillars:

* **SceneGraph (XML):** This handles the **View**. We use XML to define the UI hierarchy, layouts, and animations. By using the SceneGraph's rendering engine, the app achieves smooth 60fps transitions and handles "Focus" (remote control navigation) natively.
* **BrightScript (.brs):** This handles the **Logic**. It is a powerful, event-driven language that manages data fetching, video playback control, and user interactions.

---

## Key Technical Implementations

* **Multi-Threading:** The app separates the UI thread (SceneGraph) from the logic thread (Task nodes) to prevent the interface from freezing during network requests.
* **Video Node Integration:** Utilizes the native Roku `Video` node, ensuring hardware-accelerated decoding for various formats like HLS, DASH, and MP4.
* **Data Binding:** Employs **Field Observers** to automatically update the UI whenever the BrightScript logic receives new content or updates a state.

---

## Quick Installation

1.  Enable **Developer Mode** on your Roku device.
2.  Compress the project root into a `.zip` file.
3.  Upload the package via the **Roku Development Application Installer** (accessed via the device's IP address).

---
*Developed by Victor Vasquez*