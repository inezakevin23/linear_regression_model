import 'package:edulabour_rwanda/service/prediction_service.dart';
import 'package:flutter/material.dart';

import '../data/prediction_fields.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controllers = {
    for (final field in predictionFields) field.key: TextEditingController(),
  };
  final _predictionService = PredictionService();

  bool _isLoading = false;
  bool _isError = false;
  String _message = 'Your prediction will appear here.';
  PredictionResult? _result;

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _predictionService.dispose();
    super.dispose();
  }

  Future<void> _submitPrediction() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      setState(() {
        _result = null;
        _isError = true;
        _message = 'Please fix the highlighted fields above before predicting.';
      });
      return;
    }

    final inputs = {
      for (final field in predictionFields)
        field.key: int.parse(_controllers[field.key]!.text.trim()),
    };

    setState(() {
      _isLoading = true;
      _result = null;
      _isError = false;
      _message = 'Requesting prediction from Render API...';
    });

    try {
      final prediction = await _predictionService.predict(inputs);
      if (!mounted) return;
      setState(() {
        _result = prediction;
        _isError = false;
        _message = 'Prediction completed successfully.';
      });
    } on PredictionApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _result = null;
        _isError = true;
        _message = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _result = null;
        _isError = true;
        _message = 'Network error: Unable to reach the API.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatRwf(double value) {
    final formatted = value.round().toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    return 'RWF $formatted / month';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('EduLabour Rwanda')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Monthly Cash Earnings Predictor',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Enter the 11 NISR survey values within the allowed ranges below.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ...predictionFields.map(_buildInputField),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: _isLoading ? null : _submitPrediction,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: Text(_isLoading ? 'Predicting...' : 'Predict'),
                ),
                const SizedBox(height: 16),
                _buildResultArea(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(PredictionField field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: _controllers[field.key],
        keyboardType: TextInputType.number,
        textInputAction: field == predictionFields.last
            ? TextInputAction.done
            : TextInputAction.next,
        decoration: InputDecoration(
          labelText: '${field.label} (${field.key})',
          helperText: '${field.description} ${field.rangeHint}',
          helperMaxLines: 2,
          border: const OutlineInputBorder(),
        ),
        validator: (rawValue) {
          final value = rawValue?.trim() ?? '';
          if (value.isEmpty) return 'This field is required.';
          final parsed = int.tryParse(value);
          if (parsed == null) return 'Enter a valid whole number.';
          if (parsed < field.minimum || parsed > field.maximum) {
            return 'Enter a value from ${field.minimum} to ${field.maximum}.';
          }
          return null;
        },
        onFieldSubmitted: (_) {
          if (field == predictionFields.last) _submitPrediction();
        },
      ),
    );
  }

  Widget _buildResultArea(ThemeData theme) {
    final bgColor = _isError
        ? theme.colorScheme.errorContainer
        : theme.colorScheme.primaryContainer;
    final textColor = _isError
        ? theme.colorScheme.onErrorContainer
        : theme.colorScheme.onPrimaryContainer;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: _result != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatRwf(_result!.monthlyEarningsRwf),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Model: ${_result!.modelName}',
                  style: TextStyle(color: textColor),
                ),
              ],
            )
          : Text(
              _message,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
            ),
    );
  }
}
