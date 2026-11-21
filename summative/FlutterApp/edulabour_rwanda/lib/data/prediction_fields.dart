class PredictionField {
  const PredictionField({
    required this.key,
    required this.label,
    required this.description,
    required this.minimum,
    required this.maximum,
  });

  final String key;
  final String label;
  final String description;
  final int minimum;
  final int maximum;
  String get rangeHint => 'Enter a whole number from $minimum to $maximum.';
}

const List<PredictionField> predictionFields = [
  PredictionField(
    key: 'a04',
    label: 'Age',
    description: 'Age at last birthday, in years.',
    minimum: 16,
    maximum: 98,
  ),
  PredictionField(
    key: 'b02b',
    label: 'Completed years of education',
    description: 'Years completed at the reported education level.',
    minimum: 0,
    maximum: 14,
  ),
  PredictionField(
    key: 'd24',
    label: 'Years of work experience',
    description: 'Total years the person has been working.',
    minimum: 0,
    maximum: 70,
  ),
  PredictionField(
    key: 'a01',
    label: 'Sex code',
    description: '1 = Male, 2 = Female (NISR codebook).',
    minimum: 1,
    maximum: 2,
  ),
  PredictionField(
    key: 'code_ur',
    label: 'Urban / rural residence code',
    description: '1 = Urban, 2 = Rural (NISR codebook).',
    minimum: 1,
    maximum: 2,
  ),
  PredictionField(
    key: 'province',
    label: 'Province code',
    description: '1 = Kigali, 2 = South, 3 = West, 4 = North, 5 = East.',
    minimum: 1,
    maximum: 5,
  ),
  PredictionField(
    key: 'a05',
    label: 'Marital status code',
    description: 'Enter the numeric category from the NISR codebook.',
    minimum: 1,
    maximum: 7,
  ),
  PredictionField(
    key: 'b02a',
    label: 'Highest education level code',
    description:
        'Enter the highest education-level category from the NISR codebook.',
    minimum: 1,
    maximum: 8,
  ),
  PredictionField(
    key: 'b07',
    label: 'Currently attending TVET code',
    description: 'Enter the response code recorded in the NISR survey.',
    minimum: 1,
    maximum: 9,
  ),
  PredictionField(
    key: 'b08',
    label: 'Has learned a TVET course code',
    description: 'Enter the response code recorded in the NISR survey.',
    minimum: 1,
    maximum: 9,
  ),
  PredictionField(
    key: 'main_sect',
    label: 'Main economic sector code',
    description: 'Enter the NISR ISIC economic-sector code.',
    minimum: 1,
    maximum: 21,
  ),
];
