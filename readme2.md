# פרויקט מסכם דאבופס – מערכת אירועי חברה (Holiday Events)

הפרויקט הזה מציג תהליך אוטומטי מלא של CI/CD עבור אפליקציית חברה פנימית הכתובה ב-Node.js. המטרה היא לקחת את הקוד מ-GitHub, לבדוק אותו, לבנות ממנו קונטיינר של דוקר, ולפרוס אותו באופן אוטומטי לחלוטין על שרת וירטואלי מרוחק (VM) בעזרת אנסיבל – ללא שום התערבות ידנית בזמן ההגשה.

## איך התהליך (Pipeline) עובד?

1. **עבודה עם Git:** מפתחים ומעדכנים את קוד האפליקציה או קבצי האוטומציה ודוחפים (Push) ל-Branch הראשי `main`.
2. **זיהוי אוטומטי בג'נקינס (CI):** שרת הג'נקינס מוגדר עם מנגנון `pollSCM` שבודק את ה-Repository ב-GitHub בכל דקה עגולה. ברגע שיש קוד חדש, ה-Pipeline מתחיל לרוץ לבד.
3. **התקנה ובדיקת תקינות:** ג'נקינס מתקין את ה-Dependencies (`npm install`) ומריץ בדיקת סינטקס מהירה לקוד (`node --check server.js`) כדי לוודא שהשרת לא יקרוס.
4. **בניית ה-Docker Image:** ג'נקינס בונה את ה-Image המקומי של האפליקציה ומעדכן אותו לגרסה האחרונה (`holiday-app:latest`).
5. **פריסה אוטומטית עם Ansible (CD):** ג'נקינס מפעיל את ה-Playbook של אנסיבל באופן אוטומטי. אנסיבל מתחבר ב-SSH לשרת הוירטואלי, מוריד את הקוד המעודכן מ-GitHub, בונה את ה-Image בתוך ה-VM, עוצר את הקונטיינר הישן ומריץ את הקונטיינר החדש בפורט `3000`.
6. **בדיקת בריאות (Health Check):** האנסיבל מחכה 3 שניות כדי לתת לאפליקציה לעלות, ומריץ פקודת `curl` פנימית לכתובת ה-`/health` של האפליקציה כדי לוודא שהגרסה החדשה באמת חיה ועובדת.

---

## קבצי ההגדרה של הפרויקט

### 1. קובץ ה-Dockerfile
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
ENV NODE_ENV=production
EXPOSE 3000
CMD ["npm", "start"]
```

### 2. קובץ ה-Jenkinsfile
```groovy
pipeline {
    agent any
    triggers {
        pollSCM('* * * * *') // בדיקה אוטומטית של הגיט בכל דקה
    }
    stages {
        stage('Checkout Code') {
            steps {
                checkout scm 
            }
        }
        stage('Install Dependencies') {
            steps {
                sh 'npm install'
            }
        }
        stage('Test') {
            steps {
                sh 'node --check server.js'
            }
        }
        stage('Build image') {
            steps {
                sh 'docker build -t holiday-app:latest .'
            }
        }
        stage('Deploy with Ansible') {
            steps {
                echo 'Triggering Ansible Deployment Playbook safely with Vault...'
                sh 'ansible-playbook -i inventory.ini deploy.yml --vault-password-file .vault_pass -e @secrets.yml'
            }
        }

    }
}
```

---

## 🛡️ Security & Secret Management (Ansible Vault)

To comply with real-world DevOps best practices, this project does **not** hardcode plain-text passwords or SSH keys inside the code or inventory files. 

1. **Encrypted Secrets (`secrets.yml`):** All sensitive infrastructure credentials (like the target server's SSH and sudo passwords) are stored inside an encrypted YAML file utilizing **Ansible Vault**.
2. **Automated Decryption (`.vault_pass`):** The Jenkins pipeline uses a local, non-interactive password file to securely unlock the vault at runtime.
3. **Repository Protection (`.gitignore`):** The decryption key `.vault_pass` is strictly excluded via `.gitignore` to guarantee that no plain-text passwords are ever pushed to the public GitHub repository.

---

## הוראות הרצה ובדיקה להגשה

בזמן ההגנה על הפרויקט מול המרצה, אין צורך להקליד שום פקודה ידנית בטרמינל כדי לבצע Deployment:

1. ודא שהשרת הוירטואלי שלך (Linux VM) דלוק ומחובר לרשת בכתובת `192.168.128.131`.
2. בצע שינוי קטן בקוד האפליקציה או בקובץ ה-README במחשב שלך.
3. דחף את השינוי ל-GitHub בעזרת הפקודות הבאות:
   ```bash
   git add .
   git commit -m "demo: automatic deployment check"
   git push origin main
   ```
4. פתח את הדפדפן בכתובת של ג'נקינס: `http://localhost:8020`.
5. בתוך פחות מדקה תוכל להראות למרצה שה-Build התחיל לרוץ **לבד**, סיים בהצלחה את הבנייה, הפעיל את אנסיבל, והפך לירוק (Success).

---

## נקודות קצה של ה-API באפליקציה

לאחר שהפריסה מסתיימת בהצלחה, האפליקציה זמינה בשרת ה-VM שלכם בפורט `3000`:

| Method | Path | Description |
| :--- | :--- | :--- |
| **GET** | `/health` | בדיקת תקינות השרת. מחזיר סטטוס healthy. |
| **GET** | `/api/events` | קבלת רשימת כל אירועי החברה הקיימים במערכת. |
| **GET** | `/api/events/:id` | קבלת מידע על אירוע ספציפי לפי ה-ID שלו. |
| **POST** | `/api/register` | הרשמה של עובד לאירוע (מוריד אוטומטית מקום פנוי מהאירוע). |
