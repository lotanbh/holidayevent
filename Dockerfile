# השתמשות באימג' רשמי של Node.js (גרסה 18 ומעלה כפי שמוגדר ב-engines)
FROM node:18-alpine

# הגדרת תיקיית העבודה בתוך הקונטיינר
WORKDIR /app

# העתקת קבצי הפקג' כדי להתקין את ה-dependencies תחילה (ניצול מנגנון ה-Cache של דוקר)
COPY package*.json ./

# התקנת התלויות עבור ה-Production בלבד
RUN npm ci --only=production

# העתקת כל שאר קבצי הפרויקט לתוך הקונטיינר
COPY . .

# הגדרת משתנה סביבה מומלץ ל-Node.js
ENV NODE_ENV=production

# חשיפת הפורט שהאפליקציה מאזינה לו
EXPOSE 3000

# הפקודה שתריץ את האפליקציה כשהקונטיינר יעלה (לפי ה-scripts שלכם)
CMD ["npm", "start"]
