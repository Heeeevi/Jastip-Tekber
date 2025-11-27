# 🚪 Logout Feature & Auth Flow Implementation

## ✅ Yang Sudah Diimplementasi:

### 1. **Logout Button** (3 Lokasi)

#### A. Home Screen (Buyer Mode)
**Lokasi**: Top right corner → Menu (⋮)

```dart
// Header dengan logout menu
PopupMenuButton<String>(
  icon: Icon(Icons.more_vert),
  onSelected: (value) {
    if (value == 'logout') {
      _showLogoutDialog();
    }
  },
  itemBuilder: (context) => [
    PopupMenuItem(
      value: 'logout',
      child: Row(
        children: [
          Icon(Icons.logout, color: Colors.red),
          Text('Logout', style: TextStyle(color: Colors.red)),
        ],
      ),
    ),
  ],
)
```

**Features:**
- ✅ Popup menu dengan icon logout
- ✅ Confirmation dialog
- ✅ Navigate ke login screen
- ✅ Clear all previous routes

#### B. Seller Dashboard
**Lokasi**: Top right corner → Menu (⋮)

Same implementation as Home Screen!

**Features:**
- ✅ Popup menu dengan icon logout
- ✅ Confirmation dialog
- ✅ Navigate ke login screen
- ✅ Clear all previous routes

---

### 2. **Authentication Flow**

#### Flow Sign Up → Sign In → Home

```
START
  ↓
[Landing Page / Initial]
  ↓
┌─────────────┐
│  SIGN UP    │ ← User belum punya akun
│  (Register) │
└─────────────┘
  ↓
Input:
- Email
- Full Name  
- Password (min 6 char)
  ↓
Click "Sign Up"
  ↓
✅ Account Created
✅ Auto Signed In
  ↓
Navigate to HOME
  ↓
┌─────────────┐
│  HOME       │ ← User masuk aplikasi
│  (Buyer)    │
└─────────────┘
  │
  ├──→ Toggle to Seller Mode
  │
  └──→ Click Logout Menu (⋮)
       ↓
     Confirmation Dialog
       ↓
     Click "Logout"
       ↓
   Navigate to LOGIN
       ↓
┌─────────────┐
│  SIGN IN    │ ← User sudah punya akun
│  (Login)    │
└─────────────┘
  ↓
Input:
- Email
- Password
  ↓
Click "Sign In"
  ↓
✅ Authenticated
  ↓
Navigate to HOME
```

---

### 3. **Screen Navigation Links**

#### Sign Up Screen
```dart
Widget _buildBottomText() {
  return GestureDetector(
    onTap: () {
      Navigator.pushReplacementNamed(context, '/login');
    },
    child: Text.rich(
      TextSpan(
        text: 'Have Account? ',
        children: [
          TextSpan(
            text: 'Sign In',  // ← Link ke Login
            style: TextStyle(
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    ),
  );
}
```

**User Journey:**
```
Sign Up Screen:
┌────────────────────────────┐
│ Email: ___________________│
│ Name:  ___________________│
│ Pass:  ___________________│
│                            │
│     [  Sign Up  ]          │
│                            │
│ Have Account? Sign In      │ ← Click here
└────────────────────────────┘
           ↓
     Navigate to Login
```

#### Login Screen
```dart
Widget _buildBottomLink() {
  return GestureDetector(
    onTap: () {
      Navigator.pushReplacementNamed(context, '/signup');
    },
    child: RichText(
      text: TextSpan(
        text: "Don't Have Account? ",
        children: [
          TextSpan(
            text: 'Sign Up',  // ← Link ke Sign Up
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
  );
}
```

**User Journey:**
```
Login Screen:
┌────────────────────────────┐
│ Email: ___________________│
│ Pass:  ___________________│
│                            │
│ Forgot password?           │
│                            │
│     [  Sign In  ]          │
│                            │
│ Don't Have Account? Sign Up│ ← Click here
└────────────────────────────┘
           ↓
     Navigate to Sign Up
```

---

### 4. **Logout Dialog Implementation**

```dart
void _showLogoutDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await _handleLogout();
            },
            child: Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      );
    },
  );
}
```

**Dialog Preview:**
```
┌────────────────────────────┐
│         Logout             │
├────────────────────────────┤
│                            │
│ Are you sure you want to   │
│ logout?                    │
│                            │
├────────────────────────────┤
│         [Cancel]  [Logout] │
└────────────────────────────┘
```

---

### 5. **Logout Handler**

```dart
Future<void> _handleLogout() async {
  try {
    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logging out...')),
    );

    // Sign out from Supabase
    // await SupabaseService().signOut(); // TODO: Implement

    // Navigate to login screen (clear all routes)
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false, // Remove ALL previous routes
    );

    // Show success
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logged out successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: ${e.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
```

**Features:**
- ✅ Loading indicator
- ✅ Clear navigation stack
- ✅ Success feedback
- ✅ Error handling

---

## 🎯 User Experience Flow

### Complete Journey:

#### Scenario 1: New User (Belum punya akun)
```
1. User buka app
   ↓
2. Klik "Sign Up"
   ↓
3. Isi form (email, name, password)
   ↓
4. Klik "Sign Up" button
   ↓
5. ✅ "Welcome, [Name]! Account created"
   ↓
6. Auto signed in
   ↓
7. Navigate ke Home screen
   ↓
8. User bisa pakai app
   ↓
9. Klik menu (⋮) → Logout
   ↓
10. Confirm logout
    ↓
11. Back to Login screen
```

#### Scenario 2: Existing User (Sudah punya akun)
```
1. User buka app
   ↓
2. Sudah di Login screen
   ↓
3. Isi email & password
   ↓
4. Klik "Sign In"
   ↓
5. ✅ Authenticated
   ↓
6. Navigate ke Home screen
   ↓
7. User bisa pakai app
   ↓
8. Klik menu (⋮) → Logout
   ↓
9. Confirm logout
   ↓
10. Back to Login screen
```

#### Scenario 3: User Salah Screen
```
Situation A: Di Sign Up tapi sudah punya akun
  ↓
  Klik "Have Account? Sign In"
  ↓
  Navigate ke Login screen
  ↓
  Login dengan credentials yang ada

Situation B: Di Login tapi belum punya akun
  ↓
  Klik "Don't Have Account? Sign Up"
  ↓
  Navigate ke Sign Up screen
  ↓
  Register akun baru
```

---

## 📱 UI Elements

### Logout Button Location:

#### Home Screen:
```
┌─────────────────────────────────────┐
│ [👤]  JasTip         [🔔] [⋮]      │ ← Logout menu here
├─────────────────────────────────────┤
│ [Buyer] [Seller]                    │
│                                     │
│ Search: ________________________    │
│                                     │
│ Popular Sellers                     │
│ ...                                 │
└─────────────────────────────────────┘
```

#### Seller Dashboard:
```
┌─────────────────────────────────────┐
│ [👤]       JasTip      [🔔] [⋮]    │ ← Logout menu here
├─────────────────────────────────────┤
│ [Buyer] [Seller]                    │
│                                     │
│ Orders Overview                     │
│ ...                                 │
└─────────────────────────────────────┘
```

---

## 🔧 Implementation Details

### Files Modified:

1. **`lib/screens/home_screen.dart`**
   - ✅ Added PopupMenuButton with logout option
   - ✅ Added _showLogoutDialog()
   - ✅ Added _handleLogout()

2. **`lib/screens/seller_dashboard_screen.dart`**
   - ✅ Added PopupMenuButton with logout option
   - ✅ Added _showLogoutDialog()
   - ✅ Added _handleLogout()

3. **`lib/screens/sign_up_screen.dart`**
   - ✅ Already has link to Sign In
   - ✅ Auto navigate to home after sign up

4. **`lib/screens/login_screen.dart`**
   - ✅ Already has link to Sign Up
   - ✅ Navigate to home after sign in

### Navigation Strategy:

#### pushReplacementNamed
```dart
// Ganti screen sekarang dengan screen baru
Navigator.pushReplacementNamed(context, '/login');

Use case:
- Sign Up → Sign In
- Sign In → Sign Up
```

#### pushNamedAndRemoveUntil
```dart
// Navigate & hapus semua route sebelumnya
Navigator.pushNamedAndRemoveUntil(
  context,
  '/login',
  (route) => false, // Remove all routes
);

Use case:
- Logout (clear navigation stack)
- Sign Up → Home (clear stack)
```

---

## 🎓 Next Steps (TODO)

### Priority 1: Connect to Supabase
```dart
Future<void> _handleLogout() async {
  // Uncomment this line:
  await SupabaseService().signOut();
  
  // Rest of code...
}
```

### Priority 2: Persist Login State
```dart
// Check if user is already logged in
@override
void initState() {
  super.initState();
  _checkAuthState();
}

Future<void> _checkAuthState() async {
  final session = supabase.auth.currentSession;
  if (session != null) {
    // User already logged in
    Navigator.pushReplacementNamed(context, '/home');
  }
}
```

### Priority 3: Add Loading States
- ✅ Login screen already has loading
- ✅ Sign up screen already has loading
- ✅ Logout already has loading
- ⚠️ Need to add to profile screens

---

## 📊 Testing Checklist

### Test Logout:
- [ ] Click logout menu from Home screen
- [ ] Confirm dialog appears
- [ ] Click "Logout" → navigate to Login
- [ ] Session cleared (can't go back to Home)
- [ ] Click "Cancel" → stay on Home

### Test Sign Up → Sign In Flow:
- [ ] Register new user → auto navigate to Home
- [ ] Logout → back to Login
- [ ] Login with same credentials → success

### Test Sign In → Sign Up Flow:
- [ ] Try login with non-existent email → fail
- [ ] Click "Don't Have Account? Sign Up"
- [ ] Navigate to Sign Up screen
- [ ] Register → auto navigate to Home

### Test Navigation Links:
- [ ] From Sign Up → click "Have Account? Sign In" → go to Login
- [ ] From Login → click "Don't Have Account? Sign Up" → go to Sign Up
- [ ] Back button behavior correct

---

## 📝 Summary

### ✅ Implemented:
1. **Logout button** di Home & Seller Dashboard (menu ⋮)
2. **Logout confirmation dialog** dengan Cancel/Logout options
3. **Logout handler** with loading & success feedback
4. **Clear navigation stack** saat logout
5. **Sign Up ↔ Sign In links** untuk easy navigation
6. **Auto sign in** setelah register

### 🎯 User Flow:
```
Sign Up (new user) → Auto Signed In → Home
                                      ↓
                                   Logout
                                      ↓
Sign In (existing) ─────────────→ Home
```

### 📱 UI Locations:
- Logout: Top right menu (⋮) di Home & Seller Dashboard
- Sign Up link: Bottom of Login screen
- Sign In link: Bottom of Sign Up screen

---

**Files Updated:**
- ✅ `lib/screens/home_screen.dart` - Added logout
- ✅ `lib/screens/seller_dashboard_screen.dart` - Added logout
- ✅ `lib/screens/sign_up_screen.dart` - Already has link to Sign In
- ✅ `lib/screens/login_screen.dart` - Already has link to Sign Up

**Status**: Ready to test! 🚀
**Next**: Connect logout to Supabase.signOut()
