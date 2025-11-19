class ADRQuestionsService {
  static final List<ADRQuestion> questions = [
    ADRQuestion(
      id: 1,
      question: "Did the Adverse event appear after the suspected drug was administered?",
      options: {
        'Yes': 2,
        'No': -1,
        'Not Sure': 0,
      },
    ),
    ADRQuestion(
      id: 2,
      question: "Did the adverse reaction improve when the drug was discontinued or a specific antagonist was given?",
      options: {
        'Yes': 1,
        'No': 0,
        'Not Sure': 0,
      },
    ),
    ADRQuestion(
      id: 3,
      question: "Did the adverse reaction reappear upon readministration of the drug?",
      options: {
        'Yes': 2,
        'No': -2,
        'Not Sure': 0,
      },
    ),
    ADRQuestion(
      id: 4,
      question: "Were there alternative causes (other than the drug) that could have caused the reaction?",
      options: {
        'Yes': -2,
        'No': 2,
        'Not Sure': 1,
      },
    ),
    ADRQuestion(
      id: 5,
      question: "Was the patient taking any other medications at the same time?",
      options: {
        'Yes': 1,
        'No': 2,
        'Not Sure': 1,
      },
      hasSubQuestion: true,
      subQuestion: "Did any of these drugs have known interactions with the suspected drug?",
      subOptions: {
        'Yes': -1,
        'No': 1,
      },
    ),
    ADRQuestion(
      id: 6,
      question: "Was the suspected drug taken with food or alcohol?",
      options: {
        'Yes': 1,
        'No': 2,
        'Not Sure': 1,
      },
      hasSubQuestion: true,
      subQuestion: "Does the drug have known interactions with that food/alcohol?",
      subOptions: {
        'Yes': 0,
        'No': 1,
      },
    ),
    ADRQuestion(
      id: 7,
      question: "Did the patient have any previous history of allergy or adverse reaction to this drug or similar drugs?",
      options: {
        'Yes': 2,
        'No': 0,
        'Not Sure': 1,
      },
    ),
    ADRQuestion(
      id: 8,
      question: "Was the reaction confirmed by any objective evidence (e.g., lab results, imaging, biopsy, etc.)?",
      options: {
        'Yes': 2,
        'No': 0,
        'Not Sure': 1,
      },
    ),
    ADRQuestion(
      id: 9,
      question: "Was the reaction dose-related? (i.e., severity increased with higher dose)",
      options: {
        'Yes': 2,
        'No': 0,
        'Not Sure': 1,
      },
    ),
    ADRQuestion(
      id: 10,
      question: "Is the adverse reaction listed in the approved product label or literature?",
      options: {
        'Yes': 2,
        'No': 1,
        'Not Sure': 1,
      },
    ),
  ];

  static String getCausalityAssessment(int score) {
    if (score >= 15) return 'Definite';
    if (score >= 8) return 'Probable';
    if (score >= 3) return 'Possible';
    if (score >= 0) return 'Unlikely';
    return 'Doubtful';
  }
}

class ADRQuestion {
  final int id;
  final String question;
  final Map<String, int> options;
  final bool hasSubQuestion;
  final String? subQuestion;
  final Map<String, int>? subOptions;

  ADRQuestion({
    required this.id,
    required this.question,
    required this.options,
    this.hasSubQuestion = false,
    this.subQuestion,
    this.subOptions,
  });
}