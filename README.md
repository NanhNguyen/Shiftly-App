# Shiftly - Schedule Management App

Shiftly is a comprehensive schedule management application designed for interns and managers. It allows easy registration of work shifts and leave requests, with a streamlined approval process for managers.

## Project Structure

This is a monorepo containing both the backend and frontend:

- `/backend`: NestJS application using Mongoose (MongoDB).
- `/frontend`: Flutter application for Android, iOS, and Web.

## Deployment on Render

To deploy this project on Render:

### Backend (NestJS)
1. Create a new **Web Service**.
2. Connect this repository.
3. Set **Root Directory** to `backend`.
4. Set **Build Command** to `npm install && npm run build`.
5. Set **Start Command** to `node dist/main`.
6. Add environment variables (e.g., `MONGO_URI`, `JWT_SECRET`).

### Frontend (Flutter Web - optional)
1. Create a new **Static Site**.
2. Connect this repository.
3. Set **Root Directory** to `frontend`.
4. Set **Build Command** to `flutter build web --release`.
5. Set **Publish Directory** to `build/web`.

## Key Features
- **Batch Grouping**: Multiple day requests are grouped into single manageable items.
- **Unique Staff Count**: Managers can see the exact number of people scheduled per day.
- **Role-Based Access**: Specialized interfaces for Interns, Managers, and HR.
- **Notifications**: Real-time notifications for schedule status updates and new requests.

## Rebranding
The app was recently rebranded from "Schedule Pro" to **Shiftly**.
