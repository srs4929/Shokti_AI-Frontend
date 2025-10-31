# Shokti - AI-Powered Household Energy Monitoring & Optimization App

---

## 1. Overview

Shokti is an AI-powered app designed to help households in Bangladesh monitor and reduce electricity waste. By combining IoT, AI, and an intuitive mobile interface, Shokti provides real-time energy usage, cost insights, anomaly detection, and personalized recommendations. The goal is to save money, reduce environmental impact, and ease pressure on the national power system.

---

## 2. Problem Statement
In Bangladesh, most electricity is generated using a mix of natural gas, coal, and hydropower. Generating this energy consumes resources, incurs costs, and impacts the environment.  

However, households often waste energy by leaving lights, fans, or other devices on unnecessarily. This not only wastes electricity but also the resources used to produce it. Many areas in Bangladesh still face power shortages and load shedding, so inefficient energy usage worsens the problem.  

With rising energy demand and climate change becoming a serious threat, households need to **use electricity smartly and efficiently**. Every unit of saved energy benefits the environment, saves money, and reduces pressure on the national power system.

---

## 3. Proposed Solution
Shokti is an **intelligent energy management system** that combines a compact IoT device (ESP32 + current sensor) with an AI-powered mobile app to help families use electricity more wisely.

**Key Features:**

- **Real-time Monitoring:** The app shows electricity usage per room or device continuously, allowing users to see exactly where energy is being used or wasted.

- **Smart AI Analysis:** The Chronos AI model detects unusual patterns, predicts potential energy waste, and learns household usage behavior over time to provide accurate recommendations.

- **Actionable Alerts & Guidance:** Users receive timely notifications when energy usage exceeds thresholds or anomalies are detected. The AI chatbot delivers personalized advice in **Bangla-English** to help households reduce waste and save money effortlessly.

- **Threshold Tracking & History:** The app highlights when usage goes above normal levels and keeps a record of past consumption. Users can quickly see which months stayed within limits and which went over.

- **Intuitive, User-Friendly Interface:** Shokti translates complex electricity data into clear visualizations, showing both usage and cost in real-time. Even non-technical users can easily understand where energy is being wasted and take action.

---

## 4. Technology Stack

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

## 5. System Architecture
<img width="3805" height="1993" alt="Image" src="https://github.com/user-attachments/assets/1d750660-7952-4c08-9954-fe8beda7a476" />

---


