# App Store Connect — copy-paste sheet for Boring Switch 1.0

Everything below is ready to paste into App Store Connect, in the order the
fields appear. The app is a **paid app at $0.99** — there is no in-app
purchase, so skip any IAP screens entirely.

---

## 1. New App (My Apps → + → New App)

| Field | Value |
|---|---|
| Platforms | iOS |
| Name | `Boring Switch` |
| Primary language | English (U.S.) |
| Bundle ID | `com.boringswitch.app` |
| SKU | `boringswitch-001` |
| User access | Full Access |

If the name "Boring Switch" is taken, fallbacks: `Boring Switch — Click Toy`,
`Just a Boring Switch`.

---

## 2. Pricing and Availability

- Price: **$0.99 (USD)** — pick the 0.99 price point, let Apple auto-set other territories
- Availability: all territories (default)

---

## 3. Version Information (1.0)

**Promotional text** (170 chars max):

```
The perfect click, now on your phone. Five switches, four materials, eight colors — and a counter that remembers every single flip. Forever.
```

**Description**:

```
A light switch. It turns the light on. It turns the light off.

That's it. That's the app.

But the click — the click is perfect. Every switch has its own satisfying sound and haptic feel, tuned like a mechanical keyboard for your thumb. Flip it while you think. Flip it while you wait. Flip it because it's there.

EVERYTHING INCLUDED
• 5 switch styles: Classic Toggle, Rocker, Push Button, Knife Switch, Pull Chain
• 4 materials — plastic, brass, steel, wood — each with its own click sound
• 8 wall plate colors, from Cloud White to Charcoal
• Real haptics matched to every switch

YOUR LIFE'S WORK, COUNTED
• Every flip is recorded to your lifetime total. Forever.
• Daily streaks, best day, average per day
• A home screen widget so you never lose sight of the number
• Earn a shareable Certificate of Dedication ("Nothing was accomplished.")

AND SOMETIMES…
Occasionally, something strange happens. We won't say what. People who've seen it know.

No ads. No subscriptions. No accounts. No data collection. One purchase, one switch, infinite clicks.
```

**Keywords** (100 chars max):

```
fidget,satisfying,clicker,asmr,relax,button,toggle,calm,oddly,anxiety,soothing,tap
```

**Support URL**: `https://github.com/Dzhang921/BoringSwitch`

**Marketing URL** (optional): leave blank

**Copyright**: `2026 Jason Zhang`

---

## 4. Screenshots

Already generated in this repo at the exact required sizes — drag the whole
folder into the upload area, in this order (01→05):

- iPhone 6.9" (1320×2868): `screenshots/iphone-6.9/`
- iPad 13" (2064×2752): `screenshots/ipad-13/`

Order tells a story: dark room → light on → sage rocker → brass knife switch →
wood pull chain.

---

## 5. App Review Information

| Field | Value |
|---|---|
| Sign-in required | No |
| Contact first name | Jason |
| Contact last name | Zhang |
| Phone | (your phone number) |
| Email | (your email) |

**Notes**:

```
Boring Switch is a paid entertainment/fidget app. Tap the light switch to turn the light on and off; every tap increments a lifetime counter. "Customize" changes the switch style, material, and color. "Stats" shows click statistics and a shareable certificate image. All features are included in the purchase price — there are no in-app purchases, no accounts, no ads, and no data collection. A home screen widget shows the lifetime click count.
```

---

## 6. App Privacy (App Privacy section → Get Started)

- Does this app collect data? → **No, we do not collect data from this app**
- Result shown on store: "Data Not Collected"
- Privacy Policy URL: `https://github.com/Dzhang921/BoringSwitch/blob/main/PRIVACY.md`

---

## 7. Age Rating questionnaire

Answer **None / No** to every question. Result: **4+**.

---

## 8. General App Information

| Field | Value |
|---|---|
| Primary category | Entertainment |
| Secondary category | Lifestyle |
| Content rights | Does not contain third-party content |

---

## 9. Build

Upload from Xcode: **Window → Organizer → BoringSwitch 1.0 (today's archive) →
Distribute App → App Store Connect → Upload**. After ~15 min processing, select
the build on the version page. The export-compliance question is answered
automatically by the build (`ITSAppUsesNonExemptEncryption = NO`).

## 10. Before submitting

- Agreements: **Paid Applications** agreement must be Active (Business →
  Agreements, Tax, and Banking) — required to sell a paid app.
- Then: **Submit for Review**.
