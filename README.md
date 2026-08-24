# Lab 4 — VetClinic: Index & Show Views

## Objective

In this lab, you will add controllers and views to display the data you created in Lab 3. By the end, users will be able to browse lists of records and view the details of each one. **No create/edit functionality yet** — this lab focuses exclusively on read-only pages.

## Setup

In this lab you will continue working on the VetClinic application you built in Lab 3, but you must submit it in a **new repository**. Your Lab 3 repository will not be reviewed for this lab.

1. **Create a new, empty repository** on GitHub (no README, no .gitignore, no license — completely empty). Make sure it is **public** so the teaching assistant can review it.

2. In your local `vet_clinic` project from Lab 3, add the new repository as a remote and push your code:

```bash
cd vet_clinic
git remote add lab4 <your-new-repo-url>
git push -u lab4 main
```

3. Verify on GitHub that your code is now in the new repository.

4. From now on, push your Lab 4 work to this new remote:

```bash
git push lab4 main
```

5. **Submit the link to your new repository on Canvas.**

## Instructions

### 1. Generate Controllers

Generate controllers for the following resources with `index` and `show` actions:

- **Owners**
- **Pets**
- **Vets**
- **Appointments**

You do not need a controller for Treatments — they will be displayed within the Appointment show page.

### 2. Define Routes

In `config/routes.rb`, define resourceful routes for each of the four resources, but limit them to only the `index` and `show` actions. Set the root path to the Owners index page.

### 3. Index Views

Create an index view for each resource that displays a table listing all records. Each table should include the most relevant columns for that entity:

| Resource     | Columns to display                                      |
|--------------|---------------------------------------------------------|
| Owners       | Full name, email, phone, number of pets                 |
| Pets         | Name, species, breed, owner name, date of birth         |
| Vets         | Full name, email, specialization                        |
| Appointments | Date, pet name, vet name, reason, status                |

Each row should include a link to the corresponding show page (e.g., clicking an owner's name takes you to their detail page).

### 4. Show Views

Create a show view for each resource that displays all of its attributes and its related records:

**Owner show page**
- Display all owner attributes (name, email, phone, address).
- List all of the owner's pets with links to each pet's show page.

**Pet show page**
- Display all pet attributes (name, species, breed, date of birth, weight).
- Show the owner's name as a link to the owner's show page.
- List all of the pet's appointments with links to each appointment's show page.

**Vet show page**
- Display all vet attributes (name, email, phone, specialization).
- List all of the vet's appointments with links to each appointment's show page.

**Appointment show page**
- Display all appointment attributes (date, reason, status).
- Show the pet's name and the vet's name as links to their respective show pages.
- List all treatments for this appointment, displaying: name, medication, dosage, administered at, and notes.

### 5. Navigation

Add a shared navigation bar (use a partial in `app/views/layouts/`) that includes links to each of the four index pages. The navigation bar should be visible on every page.

Use Bootstrap to style the navigation bar and the rest of the application. You may use the Bootstrap CDN or install it via a gem.

### 6. Formatting

Apply the following formatting to improve readability:

- Display dates in a human-friendly format (e.g., `March 15, 2026` instead of `2026-03-15`).
- Display the appointment status as a word (e.g., "Scheduled", "Completed") instead of the raw integer value.
- Use Bootstrap classes to style tables, links, and page layout.

## Deliverables

- Controllers with `index` and `show` actions for Owners, Pets, Vets, and Appointments.
- Resourceful routes limited to `index` and `show`.
- Index pages displaying tables of records with links to show pages.
- Show pages displaying all attributes and related records with navigation between them.
- A shared navigation bar linking to all index pages.
- Bootstrap styling applied throughout the application.
