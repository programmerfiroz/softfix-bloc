lib/
├── core/                                      → App-wide reusable layer
│   ├── constants/                             → Static constants
│   │
│   ├── extension/                             → Dart extensions
│   │
│   ├── services/                              → Network, navigation, config, storage
│   │
│   ├── utils/                                 → Helper & utility functions
│   │   ├── app_validators.dart                → Form validation (email, phone, password, OTP)
│   │   ├── custom_snackbar.dart               → Global success/error snackbar
│   │   ├── helper_function.dart               → Date format, debounce, delay helpers
│   │   ├── logger.dart                        → Debug & error logging
│   │   └── ui_spacer.dart                     → SizedBox helpers (height / width)
│   │
│   └── widget/                                → Global reusable widgets
│       ├── custom_app_bar.dart                → Common AppBar
│       ├── custom_app_text.dart               → App-wide Text widget
│       ├── custom_base_widget.dart            → Base layout (SafeArea, padding)
│       ├── custom_bottom_nav_bar.dart         → Bottom navigation bar
│       ├── custom_button.dart                 → Buttons with loading state
│       ├── custom_empty_widget.dart           → Empty state UI
│       ├── custom_image_widget.dart           → Image with placeholder/error
│       ├── custom_otp_field.dart              → OTP input UI
│       ├── custom_retry_widget.dart           → Error + Retry widget
│       ├── custom_text_field.dart             → Input fields with validation
│       └── loading_widget.dart                → Global loading indicator
│
└── features/
│    └── chat/                                 → Chat related complete feature
│    │   ├── bloc/                             → State management (BLoC)
│    │   │   ├── chat_bloc.dart                → Events handle, states emit
│    │   │   │                                   → Uses core/network/api_checker.dart
│    │   │   ├── chat_event.dart               → Send, Receive, Load message events
│    │   │   ├── chat_event.dart               → Send, Receive, Load message events
│    │   │   └── chat_state.dart               → Loading, Loaded, Error states
│    │   │   
│    │   ├── data/                             → Data handling layer
│    │   │   ├── datasource/
│    │   │   │   ├── local/
│    │   │   │   │   └── chat_local_datasource.dart
│    │   │   │   │        → Hive / SharedPrefs (offline cache)
│    │   │   │   │
│    │   │   │   └── remote/
│    │   │   │   │   └── chat_remote_datasource.dart
│    │   │   │   │       → API / WebSocket calls
│    │   │   │   │       → Uses api_client, api_response, api_constants
│    │   │   │   │
│    │   │   ├── models/
│    │   │   │   └── message_model.dart
│    │   │   │        → Message JSON ↔ Dart model
│    │   │   │
│    │   │   └── repository/
│    │   │   │       ├── chat_repository.dart
│    │   │   │       │    → Repository contract
│    │   │   │       └── chat_repository_impl.dart
│    │   │   │            → Local / Remote decision
│    │   │   │            → Uses network_info.dart
│    │   │   │
│    │   │   ├── service/                          → Background & real-time services
│    │   │       └── chat_service.dart
│    │   │            → WebSocket / FCM / WebRTC
│    │   │            → Uses navigation_service.dart
│    │   │   
│    │   ├── widget/                           → Chat-specific reusable widgets
│    │   │   ├── message_bubble.dart            → Single message UI
│    │   │   ├── chat_input_field.dart          → Message typing & send UI
│    │   │   └── chat_app_bar.dart              → Chat screen AppBar
│    │   │  
│    │   └── view/                             → Screens / Pages
│    │       └── chat_screen.dart
│             → BlocProvider / BlocListener
│             → Localization & Navigation usage
