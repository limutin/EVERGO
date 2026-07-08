/// Input validation utilities for form fields
class Validators {
  // Email validation
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  // Password validation
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    return null;
  }

  // Confirm password validation
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }

  // Name validation
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    // Check if name contains at least one letter
    if (!RegExp(r'[a-zA-Z]').hasMatch(value)) {
      return 'Name must contain letters';
    }
    
    return null;
  }

  // Phone number validation (Philippine format)
  static String? phoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    
    // Remove spaces, dashes, and parentheses
    final cleanedValue = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Check if it starts with +63 or 0
    if (!RegExp(r'^(\+63|0)9\d{9}$').hasMatch(cleanedValue) &&
        !RegExp(r'^9\d{9}$').hasMatch(cleanedValue)) {
      return 'Please enter a valid Philippine phone number';
    }
    
    return null;
  }

  // Bus number validation
  static String? busNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bus number is required';
    }
    
    if (value.trim().length < 2) {
      return 'Bus number must be at least 2 characters';
    }
    
    // Check for alphanumeric and hyphens only
    if (!RegExp(r'^[a-zA-Z0-9\-]+$').hasMatch(value.trim())) {
      return 'Bus number can only contain letters, numbers, and hyphens';
    }
    
    return null;
  }

  // Plate number validation (Philippine format)
  static String? plateNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Plate number is required';
    }
    
    final cleanedValue = value.trim().toUpperCase().replaceAll(' ', '');
    
    // Philippine plate format: ABC 1234 or ABC 123 or 123 ABC
    if (!RegExp(r'^[A-Z]{2,3}\d{3,4}$').hasMatch(cleanedValue) &&
        !RegExp(r'^\d{3,4}[A-Z]{2,3}$').hasMatch(cleanedValue)) {
      return 'Please enter a valid plate number (e.g., ABC 1234)';
    }
    
    return null;
  }

  // License number validation
  static String? licenseNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'License number is required';
    }
    
    if (value.trim().length < 5) {
      return 'License number must be at least 5 characters';
    }
    
    // Check for alphanumeric and hyphens only
    if (!RegExp(r'^[a-zA-Z0-9\-]+$').hasMatch(value.trim())) {
      return 'License number can only contain letters, numbers, and hyphens';
    }
    
    return null;
  }

  // Required field validation
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Minimum length validation
  static String? minLength(String? value, int min, [String fieldName = 'This field']) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    if (value.length < min) {
      return '$fieldName must be at least $min characters';
    }
    
    return null;
  }

  // Maximum length validation
  static String? maxLength(String? value, int max, [String fieldName = 'This field']) {
    if (value != null && value.length > max) {
      return '$fieldName must not exceed $max characters';
    }
    
    return null;
  }

  // Number validation
  static String? number(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    
    if (double.tryParse(value) == null) {
      return '$fieldName must be a valid number';
    }
    
    return null;
  }

  // Positive number validation
  static String? positiveNumber(String? value, [String fieldName = 'This field']) {
    final numberError = number(value, fieldName);
    if (numberError != null) return numberError;
    
    if (double.parse(value!) <= 0) {
      return '$fieldName must be greater than 0';
    }
    
    return null;
  }

  // Text area validation (for descriptions, reports, etc.)
  static String? textArea(String? value, {int minLength = 10, int maxLength = 500}) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    
    final trimmed = value.trim();
    
    if (trimmed.length < minLength) {
      return 'Please enter at least $minLength characters';
    }
    
    if (trimmed.length > maxLength) {
      return 'Maximum $maxLength characters allowed';
    }
    
    return null;
  }

  // Alphanumeric validation
  static String? alphanumeric(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    
    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value.trim())) {
      return '$fieldName can only contain letters and numbers';
    }
    
    return null;
  }

  // Dropdown/select validation
  static String? dropdown(dynamic value, [String fieldName = 'This field']) {
    if (value == null || value.toString().trim().isEmpty) {
      return 'Please select $fieldName';
    }
    return null;
  }

  // Combine multiple validators
  static String? Function(String?) combine(List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}
