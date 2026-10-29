# EduDash: Responsive E-Learning Dashboard

A Flutter app that adapts its navigation to the screen size: a **side menu
(NavigationRail) on tablets** and a **bottom navigation bar on phones**.

**Name:** <your name>  
**Roll No:** <your roll number>  
**SDG:** 4 - Quality Education

## SDG justification
EduDash gives learners self-paced access to courses on any phone or tablet,
helping widen access to quality education. Progress tracking keeps learners
motivated, supporting lifelong learning opportunities for all.

## Features
- Responsive layout: side menu at 600 px and wider, bottom bar below that
- Dashboard with stats and a "continue learning" list
- Course search and category filters
- Course detail page with enroll / unenroll and lesson completion
- Progress tracking for each enrolled course
- Material 3 theme with light and dark mode

## Flutter concepts used
`LayoutBuilder`, `NavigationRail`, `NavigationBar`, `Scaffold`, `GridView`,
`ListView`, `Navigator.push`, `ChangeNotifier` with `ListenableBuilder`,
`IndexedStack`, `StatefulWidget`, reusable widgets

## How to run
1. Open [dartpad.dev](https://dartpad.dev) and choose New > Flutter
2. Paste the contents of `main.dart` and click Run
3. Widen the output pane past 600 px to see the side menu

Live demo: <paste your DartPad link here>

## Screenshots
| Phone: Home | Phone: Courses | Tablet: side menu | Course detail |
|---|---|---|---|
| ![](screenshots/phone_home.png) | ![](screenshots/phone_courses.png) | ![](screenshots/tablet.png) | ![](screenshots/detail.png) |
