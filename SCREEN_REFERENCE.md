# 📱 Screen Reference Guide

This document describes what each screen looks like and its functionality.

## 🎬 1. Splash Screen

**File**: `lib/features/splash/screens/splash_screen.dart`

### Visual Design
- Full-screen gradient background (mint to pink)
- Animated dot pattern background
- Center: Large white glass card with droplet emoji logo
- "DIABETA" text in gradient colors
- Tagline: "Your Health, Simplified"
- Bottom: Circular arrow button (auto-navigates after 2s)

### Functionality
- Shows for 2 seconds on app launch
- Fade-in animation for logo and text
- Slide-up animation for content
- Auto-navigates to main app
- Can tap button to skip

---

## 🏠 2. Home/Dashboard Screen

**File**: `lib/features/home/screens/home_screen.dart`

### Header Section
- "Hello, Sarah 👋" greeting (large, bold)
- Profile icon button (circular, top right)

### Alert Card (Gradient Purple)
- 📊 Icon + "Check Your Glucose" title
- Description: "It's been 4 hours since your last reading"
- White "Check Now" button

### Today's Overview Card (Glass)
- Section title: "Today's Overview"
- 3 stat cards in row:
  - 📊 145 mg/dL
  - 🎯 3 Readings
  - 📈 92% In Range

### Quick Actions (Horizontal Scroll)
- 💊 Medications (with "2 pending" badge)
- 🥗 Meal Log
- 🏃 Exercise
- Each in glass cards, icon + title

### Essentials Grid (2x2)
- 🔬 Regular Tests (HbA1c, Lipids)
- 💊 Medications (Daily Tracker)
- 🏃 Exercise (Stay Active)
- 🥗 Nutrition (Healthy Diet)
- Each in glass cards with gradient icon box

### Bottom Navigation
- 🏠 Home (active - gradient background)
- 💬 Assistant
- 📊 Reports
- ⚙️ Settings

---

## 📊 3. Glucose Tracking Screen

**File**: `lib/features/glucose/screens/glucose_tracking_screen.dart`

### Header
- Back button (left)
- "Blood Glucose" title

### Main Card (Glass)

#### Current Level Display
- Light purple gradient background box
- "Current Level" label
- Large "175" in gradient text (56px)
- "mg/dL" unit
- "Last update 30 min ago • 03:33 pm"
- Green badge: "✓ Within Normal Range"

#### 7-Day Chart
- Bar chart showing 8 days of data
- Purple gradient bars
- Days labeled 23-30
- Height represents glucose levels

#### Action Button
- Full-width gradient button
- "UPDATE NOW" text

### Add Reading Dialog (Modal)
- "New Reading" title with close button
- Glucose level input field (175)
- Reading type toggle: Before Meal / After Meal
- Additional notes textarea
- "SAVE READING" gradient button

---

## 💬 4. AI Assistant Screen

**File**: `lib/features/assistant/screens/assistant_screen.dart`

### Header
- Back button
- Robot emoji in gradient circle
- "AI Assistant" title

### Chat Area
- Date/time stamp at top
- Message bubbles alternating:
  
  **User Messages** (right-aligned):
  - White background
  - Blue gradient bubble
  - Profile icon (👤)
  - Can include images

  **AI Messages** (left-aligned):
  - White glass background
  - Robot emoji icon
  - Black text
  - Can be multi-line

### Example Conversation
User: "Can I eat this cheeseburger? My sugar was lower today."
[Burger image]

AI: "Your last recorded blood sugar level was 6 mmol/L, which is in the normal range but can rise after a high-carb meal. I wouldn't recommend having the cheeseburger right now.

A typical cheeseburger contains roughly:
• Carbohydrates: ~30-45 g
• Sugar: ~6-8 g
• Calories: ~300-350 kcal
..."

### Input Area (Bottom)
- Light purple rounded container
- Text input field: "Message..."
- 🎤 Voice button
- 📷 Camera button
- Purple gradient send button (➤)

---

## 📈 5. Reports Screen

**File**: `lib/features/reports/screens/reports_screen.dart`

### Header
- "Reports" title
- Period selector pills: Week / **Month** / Year

### Stats Grid (2x2)
- 📊 142 - Avg. Glucose (↓ 5% vs last month - green)
- 🎯 89% - In Range (↑ 3% vs last month - green)
- 📈 6.2% - Est. HbA1c (↓ 0.3% vs last month - green)
- ⏰ 124 - Total Readings (↑ 12% vs last month - green)

### Glucose Trends Card (Glass)
- "Glucose Trends" title
- Smooth line chart with gradient
- Shows 9 data points
- Purple gradient line with area fill
- Current point highlighted

### AI Insights Card (Glass)
- "AI Insights" title

**Insight 1** (Green border):
- 🎯 "Great Progress!"
- "Your glucose levels have been consistently in range for 5 days. Keep up the excellent work!"

**Insight 2** (Orange border):
- 💡 "Pattern Detected"
- "Your readings tend to spike after lunch. Consider smaller portions or a 10-minute walk after meals."

---

## ⚙️ 6. Settings Screen

**File**: `lib/features/settings/screens/settings_screen.dart`

### Header
- "Profile" title

### Profile Card (Glass)
- Large gradient circle with 👤 icon
- "Sarah Johnson" (name)
- "sarah.j@email.com" (email)
- Purple badge: "⭐ Premium Member"

### Account Settings Card (Glass)
- "Account Settings" title
- Menu items with icons and arrows:
  - 👤 Your Information
  - 💊 Your Medication
  - 📋 Health Information
  - ✏️ Edit Profile
  - ⚠️ Report an Issue
  - ℹ️ About Us

### Notifications Card (Glass)
- "Notifications" title
- Toggle items:
  - Glucose Testing (ON)
    "Daily reminders to check levels"
  - Medication Alerts (ON)
    "Never miss your medications"
  - AI Insights (ON)
    "Personalized health tips"

### Sign Out Button
- Full-width red button
- "Sign Out" text

---

## 🎨 Design Elements Used Throughout

### Glass Cards
- White background with 95% opacity
- 20px blur effect
- 24px border radius
- Subtle shadow
- White border at 30% opacity

### Gradient Buttons
- Purple to purple gradient (135° angle)
- 16px border radius
- 18px vertical padding
- White text, bold weight
- Purple shadow for depth
- Hover: Lifts up 2px

### Stat Cards
- Light purple background (8% opacity)
- 20px padding
- 16px border radius
- Large emoji icon (32px)
- Big number (24-28px, gradient colored)
- Small label below
- Optional change indicator (green/red)

### Input Fields
- Light white background (70% opacity)
- Purple border at 20% opacity
- 16px border radius
- 16px padding
- Focus: Bright purple border with shadow ring

### Bottom Navigation
- White background with 95% opacity
- 20px blur
- 80px height
- 4 items evenly spaced
- Active item: Gradient background on icon, purple label
- Inactive: Gray icons and labels

### Typography
- Headlines: 20-28px, Bold (700)
- Body: 14-17px, Regular (400)
- Labels: 11-14px, Semibold (600)
- Color: Dark gray for primary text
- Font: Inter (Google Fonts)

---

## 📐 Layout Patterns

### Screen Structure (Typical)
1. Gradient background (mint to pink)
2. SafeArea for status bar
3. CustomScrollView for scrollable content
4. Padding: 20px on sides
5. Spacing between cards: 20px
6. Bottom navigation: 80px height

### Card Spacing
- Outer padding: 20px
- Inner padding: 24px
- Between sections: 20px
- Between items in list: 12px

### Grid Layouts
- 2 columns with 15px gap
- Responsive sizing
- Consistent card heights where possible

---

## 🎯 Interactive Elements

### Buttons
- All buttons have tap/press states
- Gradient buttons lift on hover
- Ripple effect on tap
- Disabled state: 50% opacity

### Cards
- Some cards are tappable
- Slight elevation on hover
- Smooth transitions (300ms)

### Navigation
- Smooth tab switching
- No page transitions (IndexedStack)
- Active state animations

---

## 🔄 Animations

### Splash Screen
- Fade in: 0 to 1 opacity over 1s
- Slide up: Offset(0, 0.3) to Offset.zero
- Ease-out curve

### Navigation
- Icon scales and gets gradient: 300ms
- Label color changes: 300ms

### Dialogs
- Fade in background
- Scale in dialog
- Smooth open/close

---

## 💡 UI Patterns

### Repeating Patterns
1. **Glass Card** - Used for all main content areas
2. **Gradient Button** - Primary actions
3. **Stat Display** - Consistent metric layout
4. **List Item** - Medication/setting items
5. **Badge** - Status indicators

### Color Usage
- **Purple Gradient**: Primary actions, active states
- **Green**: Success, positive changes
- **Orange**: Warnings, attention needed
- **Red**: Errors, destructive actions
- **White/Glass**: Content backgrounds

---

## 📱 Responsive Considerations

- Fixed width: 375px (iPhone standard)
- Scrollable content for all screens
- Safe area padding for notches
- Bottom navigation always visible
- Cards adapt to content

---

This reference should help you understand exactly what each screen looks like and how the UI components are structured!