class PredictionField {
  const PredictionField({
    required this.key,
    required this.label,
    required this.description,
    required this.minimum,
    required this.maximum,
    this.options,
  });

  final String key;
  final String label;
  final String description;
  final int minimum;
  final int maximum;
  final Map<int, String>? options;

  String get helperText {
    if (options != null && options!.isNotEmpty) {
      final formattedOptions = options!.entries
          .map((e) => '${e.key} = ${e.value}')
          .join(', ');
      return '$formattedOptions (Range: $minimum–$maximum)';
    }
    return '$description (Range: $minimum–$maximum)';
  }
}

const sexOptions = <int, String>{1: 'Male', 2: 'Female'};

const residenceOptions = <int, String>{1: 'Urban', 2: 'Rural'};

const provinceOptions = <int, String>{
  1: 'Kigali City',
  2: 'Southern Province',
  3: 'Western Province',
  4: 'Northern Province',
  5: 'Eastern Province',
};

const maritalStatusOptions = <int, String>{
  1: 'Never married',
  2: 'Married',
  3: 'Cohabiting',
  4: 'Divorced / Separated',
  5: 'Widowed',
};

const educationOptions = <int, String>{
  1: 'None',
  2: 'Pre-primary education',
  3: 'Primary education',
  4: 'Lower secondary education',
  5: 'Upper secondary education',
  6: 'Tertiary / University education',
};

const yesNoOptions = <int, String>{1: 'Yes', 2: 'No'};

const sectorOptions = <int, String>{
  1: 'Agriculture, forestry & fishing',
  2: 'Industry (mining, manufacturing, construction)',
  3: 'Services (trade, transport, education, health, ICT)',
};

const List<PredictionField> predictionFields = [
  PredictionField(
    key: 'a04',
    label: 'Age',
    description: 'Age at last birthday in completed years',
    minimum: 16,
    maximum: 98,
  ),
  PredictionField(
    key: 'b02b',
    label: 'Completed years of education',
    description: 'Years/grade completed at the reported education level',
    minimum: 0,
    maximum: 14,
  ),
  PredictionField(
    key: 'd24',
    label: 'Years of work experience',
    description: 'Total years of work experience / job tenure',
    minimum: 0,
    maximum: 70,
  ),
  PredictionField(
    key: 'a01',
    label: 'Sex',
    description: 'Sex code',
    minimum: 1,
    maximum: 2,
    options: sexOptions,
  ),
  PredictionField(
    key: 'code_ur',
    label: 'Urban / rural residence',
    description: 'Area of residence',
    minimum: 1,
    maximum: 2,
    options: residenceOptions,
  ),
  PredictionField(
    key: 'province',
    label: 'Province',
    description: 'Rwanda province',
    minimum: 1,
    maximum: 5,
    options: provinceOptions,
  ),
  PredictionField(
    key: 'a05',
    label: 'Marital status',
    description: 'Marital status',
    minimum: 1,
    maximum: 7,
    options: maritalStatusOptions,
  ),
  PredictionField(
    key: 'b02a',
    label: 'Highest education level',
    description: 'Highest education level',
    minimum: 1,
    maximum: 6,
    options: educationOptions,
  ),
  PredictionField(
    key: 'b07',
    label: 'Currently attending TVET',
    description: 'Currently attending trade/technical skills school',
    minimum: 1,
    maximum: 2,
    options: yesNoOptions,
  ),
  PredictionField(
    key: 'b08',
    label: 'Has learned a TVET course',
    description: 'Has completed a TVET course',
    minimum: 1,
    maximum: 2,
    options: yesNoOptions,
  ),
  PredictionField(
    key: 'main_sect',
    label: 'Main economic sector',
    description: 'Main economic activity sector',
    minimum: 1,
    maximum: 3,
    options: sectorOptions,
  ),
];
