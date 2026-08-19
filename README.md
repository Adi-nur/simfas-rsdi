# SIMFAS RS Umum Darul Istiqomah

**Hospital Inventory Management System**

MedInventory Pro is a professional, modern, and comprehensive inventory management system designed for hospital operations. It streamlines the tracking of medical supplies, pharmaceuticals, and general hospital assets.

## Core Features

*   **Dashboard**: Real-time statistics for total items, low stock, expired goods, and recent activities.
*   **Master Data Management**: Centralized database for items (medicine, medical equipment, PPE, etc.), suppliers, and storage locations.
*   **Stock Management**:
    *   Incoming goods (from suppliers or other units).
    *   Outgoing goods (usage in units like ER, ICU, etc.).
    *   Internal mutations (moving items between warehouses).
    *   Stock Opname (physical inventory count).
*   **Procurement & Requests**: Workflow for unit-based supply requests and procurement processes.
*   **Alerts & Notifications**: Automatic warnings for low stock levels and approaching expiration dates.

## Technology Stack

*   **Frontend**: Flutter (Mobile & Tablet)
*   **UI Framework**: Material 3
*   **State Management**: (Planned: Provider or Bloc)
*   **Backend Interface**: (Planned: Laravel REST API)

## Getting Started

1.  Clone the repository.
2.  Run `flutter pub get` to install dependencies.
3.  Run the app using `flutter run`.

## Current Project Status

- [x] Initial Dashboard UI
- [x] Master Data Navigation
- [x] Inventory Item List View
- [x] Add New Item Form
- [x] Stock Management Navigation
- [ ] Backend API Integration
- [ ] Barcode/QR Code Scanner
- [ ] Reports and Analytics
