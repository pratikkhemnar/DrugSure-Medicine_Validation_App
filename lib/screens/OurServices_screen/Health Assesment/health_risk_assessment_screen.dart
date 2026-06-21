import 'package:drugsuremva/screens/OurServices_screen/doctor_consultancy/doctor_consultancy_system.dart';
import 'package:flutter/material.dart';

class HealthRiskAssessmentScreen extends StatefulWidget {
  const HealthRiskAssessmentScreen({super.key});

  @override
  State<HealthRiskAssessmentScreen> createState() =>
      _HealthRiskAssessmentScreenState();
}

class _HealthRiskAssessmentScreenState
    extends State<HealthRiskAssessmentScreen> {
  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();

  bool smoker = false;
  bool diabetes = false;
  bool highBP = false;
  bool exercise = false;
  bool familyHistory = false;

  bool showResult = false;
  String result = "";
  String bmiResult = "";
  String recommendation = "";

  @override
  void dispose() {
    // Always dispose controllers to prevent memory leaks
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }

  void calculateRisk() {
    // Hide keyboard when calculating
    FocusScope.of(context).unfocus();

    // Safely parse inputs to prevent app crashes
    int? age = int.tryParse(ageController.text);
    double? height = double.tryParse(heightController.text);
    double? weight = double.tryParse(weightController.text);

    if (age == null || height == null || weight == null || height <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter valid numbers in all fields"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    double bmi = weight / ((height / 100) * (height / 100));
    String bmiStatus = "";

    if (bmi < 18.5) {
      bmiStatus = "Underweight";
    } else if (bmi < 25) {
      bmiStatus = "Normal Weight";
    } else if (bmi < 30) {
      bmiStatus = "Overweight";
    } else {
      bmiStatus = "Obese";
    }

    int score = 0;
    if (age > 45) score += 2;
    if (smoker) score += 3;
    if (diabetes) score += 3;
    if (highBP) score += 2;
    if (!exercise) score += 2;
    if (familyHistory) score += 2;
    if (bmi >= 30) score += 2;

    String riskLevel;
    if (score <= 3) {
      riskLevel = "Low Risk";
      recommendation =
      "Great job! Maintain your healthy lifestyle, balanced diet, and continue regular exercise.";
    } else if (score <= 8) {
      riskLevel = "Moderate Risk";
      recommendation =
      "Monitor your health regularly. Consider adopting a stricter diet and consulting a doctor for a routine checkup.";
    } else {
      riskLevel = "High Risk";
      recommendation =
      "Please consult a healthcare professional as soon as possible and schedule a comprehensive health screening.";
    }

    setState(() {
      result = riskLevel;
      bmiResult = "BMI: ${bmi.toStringAsFixed(1)} ($bmiStatus)\nRisk Score: $score";
      showResult = true;
    });
  }

  Color getRiskColor() {
    if (result == "Low Risk") return Colors.green;
    if (result == "Moderate Risk") return Colors.orange;
    return Colors.redAccent;
  }

  Widget buildToggle(String title, bool value, IconData icon, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: SwitchListTile(
        value: value,
        activeColor: Colors.teal,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        secondary: Icon(icon, color: value ? Colors.teal : Colors.grey),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget buildTextField(
      TextEditingController controller, String hint, IconData icon) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.teal),
        labelText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.teal, width: 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Health Risk Assessment",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Basic Information",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 16),
            buildTextField(ageController, "Age (Years)", Icons.person),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: buildTextField(heightController, "Height (cm)", Icons.height),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: buildTextField(weightController, "Weight (kg)", Icons.monitor_weight),
                ),
              ],
            ),
            const SizedBox(height: 24),

            const Text(
              "Medical History & Lifestyle",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 16),
            buildToggle("Smoker", smoker, Icons.smoking_rooms, (v) => setState(() => smoker = v)),
            buildToggle("Diabetes", diabetes, Icons.bloodtype, (v) => setState(() => diabetes = v)),
            buildToggle("High Blood Pressure", highBP, Icons.favorite_border, (v) => setState(() => highBP = v)),
            buildToggle("Regular Exercise", exercise, Icons.fitness_center, (v) => setState(() => exercise = v)),
            buildToggle("Family History (Heart Disease)", familyHistory, Icons.family_restroom, (v) => setState(() => familyHistory = v)),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: calculateRisk,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  elevation: 4,
                  shadowColor: Colors.teal.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Assess My Risk",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Animated wrapper so the result pops in smoothly
            AnimatedSize(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutQuart,
              child: !showResult
                  ? const SizedBox.shrink()
                  : Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: getRiskColor().withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(
                    color: getRiskColor().withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: getRiskColor().withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.monitor_heart,
                        color: getRiskColor(),
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      result,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: getRiskColor(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        bmiResult,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      recommendation,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const DoctorConsultancySystem()));
                        },
                        icon: Icon(Icons.video_call, color: getRiskColor()),
                        label: Text(
                          "Consult a Doctor",
                          style: TextStyle(
                            color: getRiskColor(),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: getRiskColor(), width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40), // Bottom padding
          ],
        ),
      ),
    );
  }
}