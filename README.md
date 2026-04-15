# 🚀 Customer Churn Analysis & Prediction

## 🔗 Links

* 📁 GitHub Repository: https://github.com/Rimshadev12/customer-churn-analysis-
* 💼 LinkedIn: https://linkedin.com/in/rimsha-khadim-0b2316268

## 📌 Project Overview
This project analyzes customer churn behavior and identifies at-risk customers using SQL, Python, and Power BI.

The objective is to help businesses reduce customer churn by providing actionable insights and enabling targeted retention strategies.

---

## 🎯 Objective

The objective of this project is to analyze customer churn behavior and identify key factors contributing to customer attrition. 

By leveraging SQL, Python, and Power BI, the project aims to generate actionable insights and enable businesses to proactively identify high-risk customers and improve retention strategies.

---

## 🛠️ Tools & Technologies
- **SQL (PostgreSQL)** – Data warehouse design & querying  
- **Python** – Data analysis and modeling  
  - Pandas, NumPy  
  - Scikit-learn  
- **Power BI** – Interactive dashboard & visualization  
- **SQLAlchemy** – Database connection  

---

## 🧱 Data Architecture

A **star schema data warehouse** was designed:

- **Fact Table**: `fact_customer_churn`
- **Dimension Tables**:
  - `dim_customer`
  - `dim_service`
  - `dim_contract`
  - `dim_payment`

Analytical view used for reporting:
---

## 🔄 Project Workflow

### 1. Data Extraction
- Extracted data from PostgreSQL using SQLAlchemy

### 2. Data Cleaning
- Converted data types (e.g., TotalCharges to numeric)
- Handled missing values using median imputation

### 3. Feature Engineering
- Applied one-hot encoding to categorical variables

### 4. Exploratory Data Analysis
- Identified churn trends across:
  - Contract type  
  - Payment method  
  - Internet services  
  - Customer tenure  

### 5. Predictive Modeling 
- Built a Logistic Regression model to estimate churn probability  
- Evaluated using classification metrics and ROC-AUC  

### 6. Customer Segmentation
Customers were segmented based on churn probability:

| Segment      | Criteria            |
|--------------|--------------------|
| High Risk    | ≥ 75%              |
| Medium Risk  | 50–75%             |
| Low Risk     | < 50%              |

### 7. Data Output
- Stored predictions in PostgreSQL:
---

## 🔗 Project Files

- 📓 Notebook: [Churn Analysis Notebook](https://github.com/Rimshadev12/customer-churn-analysis-/blob/main/churn_analysis.ipynb)  
- 🧾 SQL Script (Includes warehouse + view creation): [churn_warehouse.sql](https://github.com/Rimshadev12/customer-churn-analysis-/blob/main/customer_churn.ipynb)  
- 📊 Dashboard: [View Dashboard](dashboard.png)
  
---

## 📊 Dashboard

An interactive Power BI dashboard was developed to monitor:

- Total Customers  
- Churn Rate  
- High-Risk Customers  
- Churn by Contract, Payment Method, and Internet Service  
- Customer Risk Segmentation  

📷 **Dashboard Preview:**  
 📊 Dashboard: [View Dashboard](dashboard.png)

---

## 📈 Key Insights

- Customers with **month-to-month contracts** have the highest churn rate  
- Higher **monthly charges** increase churn probability  
- Customers with **longer tenure** are less likely to churn  
- Certain payment methods are associated with higher churn  

---

## 💡 Business Recommendations

- Encourage long-term contracts through incentives  
- Target high-risk customers with retention campaigns  
- Improve service quality for high-churn segments  
- Monitor customers with high monthly charges  

---

## 🏁 Conclusion

This project demonstrates an end-to-end data analytics workflow:

**Data Warehousing → Data Analysis → Visualization → Business Insights**

Machine learning was used as a supporting tool for prediction and segmentation.

---

## 📬 Contact

Feel free to connect with me on LinkedIn for feedback or collaboration.
* [LinkedIn:](https://linkedin.com/in/rimsha-khadim-0b2316268/)


