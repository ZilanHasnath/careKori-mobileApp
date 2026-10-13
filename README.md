# CareKori mobile

Flutter client for the CareKori Next.js platform. It uses the same MongoDB data
through the existing REST API, with models matching the Mongoose schemas
(`Patient`, `Caregiver`, `FamilyMember`, `Admin`, `Jobs`, `PatientProgress`).

## Setup

```bash
./setup.sh
```

This generates the Android/iOS folders, adds the Android INTERNET permission,
runs `flutter pub get`.

The API base URL is set in `lib/core/config/env.dart`. Run `flutter run`.

For a plain `http://` dev server on Android add
`android:usesCleartextTraffic="true"` to the `<application>` tag.
Use `https://` in production.

## Roles

| Role | Features |
| --- | --- |
| Patient | Search and request caregivers, track requests and progress, family list, profile |
| Caregiver | Accept/reject jobs, add progress, history, finish jobs, profile |
| Family | Link patients by unique ID, view progress, profile |
| Admin | Dashboard, approve/delete users, manage jobs and admins |

## Structure

```
lib/
  core/       config, API client, theme, validators
  models/     one class per Mongoose model
  services/   API calls per role
  providers/  auth state
  screens/    auth, patient, caregiver, family, admin
  widgets/    shared UI
```
