//suggestion_utils.dart
class SuggestionUtils {
  static String getSuggestion(String weatherDesc, double temp, List<String> interests) {
    String baseSuggestion = _getBaseSuggestion(weatherDesc, temp);
    String interestSuggestion = _getInterestSuggestion(interests);

    return '$baseSuggestion${interestSuggestion.isNotEmpty ? '\n\n$interestSuggestion' : ''}';
  }

  static String _getBaseSuggestion(String weatherDesc, double temp) {
    weatherDesc = weatherDesc.toLowerCase();
    String suggestion = '';

    // Temperature-based suggestions
    if (temp > 30) {
      suggestion = '🔥 Hot weather! Perfect for beach photography or water scenes. ';
    } else if (temp > 20) {
      suggestion = '☀️ Pleasant temperature! Great for outdoor shoots. ';
    } else if (temp > 10) {
      suggestion = '⛅ Cool weather. Good for urban photography. ';
    } else {
      suggestion = '❄️ Cold conditions. Try indoor photography or winter landscapes. ';
    }

    // Weather condition-based suggestions
    if (weatherDesc.contains('clear')) {
      suggestion += 'The sky is clear - ideal for landscape and astrophotography.';
    } else if (weatherDesc.contains('cloud')) {
      suggestion += 'Cloudy skies provide soft, even lighting - perfect for portraits.';
    } else if (weatherDesc.contains('rain')) {
      suggestion += 'Rainy weather creates interesting reflections and moody atmospheres.';
    } else if (weatherDesc.contains('thunder')) {
      suggestion += 'Stormy conditions can make for dramatic landscape shots.';
    } else if (weatherDesc.contains('snow')) {
      suggestion += 'Snow offers unique white backgrounds and winter wonderland scenes.';
    } else if (weatherDesc.contains('mist') || weatherDesc.contains('fog')) {
      suggestion += 'Fog/mist creates mysterious and atmospheric compositions.';
    } else {
      suggestion += 'Good conditions for photography. Go experiment and create!';
    }

    return suggestion;
  }

  static String _getInterestSuggestion(List<String> interests) {
    if (interests.isEmpty) return '';

    List<String> suggestions = [];

    if (interests.contains('Landscape')) {
      suggestions.add("🌄 Landscape Tip: Look for leading lines and interesting foreground elements");
    }
    if (interests.contains('Portrait')) {
      suggestions.add("📷 Portrait Tip: Use natural diffused light for flattering shots");
    }
    if (interests.contains('Wildlife')) {
      suggestions.add("🦉 Wildlife Tip: Be patient and use a fast shutter speed");
    }
    if (interests.contains('Astro')) {
      suggestions.add("🌠 Astro Tip: Use long exposure and find dark sky locations");
    }
    if (interests.contains('Macro')) {
      suggestions.add("🔍 Macro Tip: Look for dewdrops or insects in the morning");
    }
    if (interests.contains('Street')) {
      suggestions.add("🏙️ Street Tip: Capture candid moments and urban patterns");
    }

    return suggestions.join('\n\n');
  }
}