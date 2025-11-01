# Shokti - AI-Powered Household Energy Monitoring & Optimization App

---

##  Overview

Shokti is an AI-powered app designed to help households in Bangladesh monitor and reduce electricity waste. By combining IoT, AI, and an intuitive mobile interface, Shokti provides real-time energy usage, cost insights, anomaly detection, and personalized recommendations. The goal is to save money, reduce environmental impact, and ease pressure on the national power system.

---

##  Problem Statement
In Bangladesh, most electricity is generated using a mix of natural gas, coal, and hydropower. Generating this energy consumes resources, incurs costs, and impacts the environment.  

However, households often waste energy by leaving lights, fans, or other devices on unnecessarily. This not only wastes electricity but also the resources used to produce it. Many areas in Bangladesh still face power shortages and load shedding, so inefficient energy usage worsens the problem.  

With rising energy demand and climate change becoming a serious threat, households need to **use electricity smartly and efficiently**. Every unit of saved energy benefits the environment, saves money, and reduces pressure on the national power system.

---

##  Solution
Shokti is an **intelligent energy management system** that combines a compact IoT device (ESP32 + current sensor) with an AI-powered mobile app to help families use electricity more wisely.

**Key Features:**

- **Real-time Monitoring:** The app shows electricity usage per room or device continuously, allowing users to see exactly where energy is being used or wasted.

- **Smart AI Analysis:** The Chronos AI model detects unusual patterns, predicts potential energy waste, and learns household usage behavior over time to provide accurate recommendations.

- **Actionable Alerts & Guidance:** Users receive timely notifications when energy usage exceeds thresholds or anomalies are detected. The AI chatbot delivers personalized advice in **Bangla-English** to help households reduce waste and save money effortlessly.

- **Threshold Tracking & History:** The app highlights when usage goes above normal levels and keeps a record of past consumption. Users can quickly see which months stayed within limits and which went over.

- **Intuitive, User-Friendly Interface:** Shokti translates complex electricity data into clear visualizations, showing both usage and cost in real-time. Even non-technical users can easily understand where energy is being wasted and take action.

---

## Technology Stack

**Hardware:**
- ESP32 Microcontroller  
- Clamp-type AC Current Sensor  
- Load Resistor  

**Software:**
- Flutter – Mobile app development  
- Hugging Face Transformers – Pattern recognition  
- fl_chart – Data visualization for graphs and trends  
- C / C++ – Embedded programming for ESP32 and sensor integration  
- Local Storage – Store usage data on device or mobile app  
- Supabase (PostgreSQL) – Store user-consented data and session history  
- Docker – Bundle AI backend and model for easy deployment  
- FastAPI – API server for chat and session management  
- Groq API – LLMs for personalized energy-saving advice  

**Dataset & Resources:**
- [UCI Electric Power Consumption Dataset](https://www.kaggle.com/datasets/uciml/electric-power-consumption-data-set)

---

## System Architecture
<img width="3805" height="1993" alt="Image" src="https://github.com/user-attachments/assets/167d437e-40e9-4178-87e4-8154cfcf1183" />

---
## Project Structure
 ```plaintext
Shokti/
├─ lib/
│  ├─ main.dart                  # App entrypoint, initializes Supabase & splash screen
│  ├─ routes.dart                # Centralized route definitions for navigation
│  ├─ Onboardpage.dart           # Original onboarding screen (carousel + CTA)
│  ├─ landingpage.dart           # Main app shell with bottom navigation
│  ├─ CustomAppBar.dart          # Reusable gradient app bar with back button
│  ├─ LandingPageAppBar.dart     # App bar variant for landing page with profile avatar
│  ├─ ChatPage.dart              # Chat UI, sends messages to backend AI endpoint
│  ├─ EnergyPage.dart            # Room-based energy UI, shows charts and cost
│  ├─ Tracker.dart               # Monthly tracker view (demo data)
│  ├─ SetUpPage.dart             # Post-signup profile setup
│  ├─ chart/
│  │   ├─ energy_chart.dart      # Line chart for daily energy usage
│  │   └─ prediction.dart        # Forecast chart for predicted energy usage
│  ├─ models/
│  │   └─ user_profile.dart      # UserProfile model, handles JSON parsing
│  ├─ utils/
│  │   ├─ beautiful_alerts.dart  # Styled snackbars and dialogs
│  │   └─ supabase_config.dart   # Supabase client initialization helper
│  └─ views/
│      ├─ OnBoardPage.dart       # Refined onboarding UI
│      ├─ Login.dart             # Login screen with Supabase auth
│      ├─ SignUp.dart            # Signup screen with Supabase auth
│      ├─ profile_page.dart      # Displays user profile with edit option
│      └─ update_profile_page.dart # Form to update user profile
├─ assets/
│  ├─ images/                    # App images (icons, illustrations, logos)
│  └─ data/
│      ├─ data.json               # Energy usage data
│      └─ predict.json            # Predicted energy usage data
└─ README.md
  ````   


## Backend Repository  

GitHub: [Shokti Backend](https://github.com/srs4929/Shokti_chat_backend.git)
## Demo Video
[Shokti Presentation](https://youtu.be/j7dwcX38_oE)

## Documentation
[Documentation.pdf](https://github.com/user-attachments/files/23280210/Team.Dev_Mavericks_Shokti_Documentation.pdf)

## Team Members
- Sumaiya Rahman Soma
- Jobaer Hossain Tamim
- Chowdhury Shafahid Rahman
