import 'package:flutter/material.dart';
import 'adr_questions_service.dart';
import 'models/adverse_event_model.dart';
import 'models/firebase_service.dart';

class ADRQuestionsScreen extends StatefulWidget {
  final Map<String, dynamic> reportData;

  const ADRQuestionsScreen({Key? key, required this.reportData}) : super(key: key);

  @override
  _ADRQuestionsScreenState createState() => _ADRQuestionsScreenState();
}

class _ADRQuestionsScreenState extends State<ADRQuestionsScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  Map<int, String> _responses = {};
  Map<int, String?> _subResponses = {};
  int _currentQuestionIndex = 0;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final questions = ADRQuestionsService.questions;

    return Scaffold(
      appBar: AppBar(
        title: Text('ADR Assessment - Question ${_currentQuestionIndex + 1}/${questions.length}'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / questions.length,
              backgroundColor: Colors.grey[300],
              color: Colors.blue,
            ),
            SizedBox(height: 20),
            Text(
              questions[_currentQuestionIndex].question,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ..._buildOptions(questions[_currentQuestionIndex]),
            if (questions[_currentQuestionIndex].hasSubQuestion &&
                _responses[questions[_currentQuestionIndex].id] == 'Yes')
              ..._buildSubOptions(questions[_currentQuestionIndex]),
            Spacer(),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildOptions(ADRQuestion question) {
    return question.options.entries.map((entry) {
      return RadioListTile<String>(
        title: Text(entry.key),
        value: entry.key,
        groupValue: _responses[question.id],
        onChanged: (value) {
          setState(() {
            _responses[question.id] = value!;
            if (value != 'Yes' && question.hasSubQuestion) {
              _subResponses[question.id] = null;
            }
          });
        },
      );
    }).toList();
  }

  List<Widget> _buildSubOptions(ADRQuestion question) {
    if (question.subOptions == null) return [];

    return [
      SizedBox(height: 16),
      Text(
        question.subQuestion!,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.blue[800],
        ),
      ),
      SizedBox(height: 8),
      ...question.subOptions!.entries.map((entry) {
        return RadioListTile<String>(
          title: Text(entry.key),
          value: entry.key,
          groupValue: _subResponses[question.id],
          onChanged: (value) {
            setState(() {
              _subResponses[question.id] = value!;
            });
          },
        );
      }).toList(),
    ];
  }

  Widget _buildNavigationButtons() {
    final questions = ADRQuestionsService.questions;
    final hasResponse = _responses.containsKey(questions[_currentQuestionIndex].id);
    final hasSubResponse = !questions[_currentQuestionIndex].hasSubQuestion ||
        _responses[questions[_currentQuestionIndex].id] != 'Yes' ||
        _subResponses.containsKey(questions[_currentQuestionIndex].id);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_currentQuestionIndex > 0)
          ElevatedButton(
            onPressed: _previousQuestion,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              foregroundColor: Colors.white,
            ),
            child: Text('Previous'),
          ),
        ElevatedButton(
          onPressed: (hasResponse && hasSubResponse) ? _nextQuestion : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
          ),
          child: Text(_currentQuestionIndex == questions.length - 1 ? 'Submit Report' : 'Next'),
        ),
      ],
    );
  }

  void _previousQuestion() {
    setState(() {
      _currentQuestionIndex--;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < ADRQuestionsService.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _calculateScoreAndSubmit();
    }
  }

  Future<void> _calculateScoreAndSubmit() async {
    setState(() {
      _isLoading = true;
    });

    try {
      int totalScore = 0;
      Map<String, dynamic> adrResponses = {};

      for (var question in ADRQuestionsService.questions) {
        final response = _responses[question.id];
        if (response != null) {
          int score = question.options[response]!;

          // Handle sub-questions
          if (question.hasSubQuestion && response == 'Yes') {
            final subResponse = _subResponses[question.id];
            if (subResponse != null) {
              score += question.subOptions![subResponse]!;
            }
          }

          totalScore += score;

          // Store responses for the report
          adrResponses['q${question.id}'] = {
            'question': question.question,
            'response': response,
            'score': score,
            if (question.hasSubQuestion && response == 'Yes')
              'subResponse': _subResponses[question.id],
          };
        }
      }

      final causalityAssessment = ADRQuestionsService.getCausalityAssessment(totalScore);

      // Create the complete report
      final report = AdverseEventReport(
        patientName: widget.reportData['patientName'],
        age: widget.reportData['age'],
        gender: widget.reportData['gender'],
        weight: widget.reportData['weight'],
        medicineName: widget.reportData['medicineName'],
        manufacturer: widget.reportData['manufacturer'],
        batchNumber: widget.reportData['batchNumber'],
        manufacturingDate: widget.reportData['manufacturingDate'],
        expiryDate: widget.reportData['expiryDate'],
        placeOfPurchase: widget.reportData['placeOfPurchase'],
        purchaseDate: widget.reportData['purchaseDate'],
        natureOfIssue: widget.reportData['natureOfIssue'],
        description: widget.reportData['description'],
        incidentDate: widget.reportData['incidentDate'],
        photoUrls: widget.reportData['photoUrls'],
        adrResponses: adrResponses,
        adrScore: totalScore,
        causalityAssessment: causalityAssessment,
        reportDate: DateTime.now(),
      );

      // Save to Firebase
      await _firebaseService.saveAdverseEventReport(report);

      // Show results
      _showResults(totalScore, causalityAssessment);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit report: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showResults(int score, String assessment) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('ADR Assessment Result'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Score: $score', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Causality Assessment: $assessment',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text('Scoring Interpretation:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            _buildInterpretationItem('≥ 15', 'Definite'),
            _buildInterpretationItem('8 to 14', 'Probable'),
            _buildInterpretationItem('3 to 7', 'Possible'),
            _buildInterpretationItem('0 to 2', 'Unlikely'),
            _buildInterpretationItem('≤ -1', 'Doubtful'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _buildInterpretationItem(String score, String meaning) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$score: ', style: TextStyle(fontWeight: FontWeight.w500)),
          Text(meaning),
        ],
      ),
    );
  }
}