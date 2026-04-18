
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HealthInformationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      appBar: AppBar(
        title: Text('Health Information & Tips',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal[700],
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Health Tips Section
            _buildSectionHeader('Daily Health Tips', Icons.health_and_safety),
            SizedBox(height: 10),
            _buildTipCard(
              icon: Icons.water_drop,
              title: 'Stay Hydrated',
              content: 'Drink at least 8 glasses (2 liters) of water daily to maintain proper body function and flush out toxins.',
            ),
            _buildTipCard(
              icon: Icons.nightlight_round,
              title: 'Quality Sleep',
              content: 'Aim for 7-9 hours of sleep nightly. Maintain a consistent sleep schedule for better rest.',
            ),
            _buildTipCard(
              icon: Icons.directions_walk,
              title: 'Regular Exercise',
              content: '30 minutes of moderate exercise daily improves cardiovascular health and boosts immunity.',
            ),

            // Nutrition Section
            _buildSectionHeader('Nutrition Guide', Icons.restaurant),
            SizedBox(height: 10),
            _buildInfoCard(
              title: 'Balanced Diet',
              points: [
                'Include fruits & vegetables (5 servings/day)',
                'Choose whole grains over refined grains',
                'Limit processed foods and added sugars',
                'Include lean proteins (fish, poultry, legumes)',
                'Healthy fats (avocados, nuts, olive oil)'
              ],
            ),

            // Common Health Concerns
            _buildSectionHeader('Common Health Concerns', Icons.medical_services),
            SizedBox(height: 10),
            _buildExpandableInfo(
              title: 'Managing Blood Pressure',
              content: '''
• Maintain healthy weight
• Reduce sodium intake (<2,300mg/day)
• Increase potassium-rich foods (bananas, spinach)
• Limit alcohol consumption
• Manage stress through meditation/yoga
• Regular blood pressure monitoring''',
            ),
            _buildExpandableInfo(
              title: 'Diabetes Prevention',
              content: '''
• Maintain healthy weight
• Exercise regularly (150 mins/week)
• Eat fiber-rich foods
• Limit sugary beverages
• Get regular check-ups
• Monitor blood sugar levels if at risk''',
            ),

            // Mental Health Section
            _buildSectionHeader('Mental Wellbeing', Icons.psychology),
            SizedBox(height: 10),
            _buildInfoCard(
              title: 'Stress Management',
              points: [
                'Practice mindfulness meditation daily',
                'Take regular breaks during work',
                'Maintain social connections',
                'Engage in hobbies and creative activities',
                'Limit screen time before bed'
              ],
            ),

            // Seasonal Health
            _buildSectionHeader('Seasonal Health Advice', Icons.wb_sunny),
            SizedBox(height: 10),
            _buildSeasonalTips(),

            // Emergency Info
            _buildSectionHeader('Emergency Information', Icons.emergency),
            SizedBox(height: 10),
            _buildEmergencyCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.teal[700], size: 28),
        SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.teal[800],
          ),
        ),
      ],
    );
  }

  Widget _buildTipCard({required IconData icon, required String title, required String content}) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.teal[100],
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.teal[700], size: 20),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[800],
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    content,
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required List<String> points}) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal[800],
              ),
            ),
            SizedBox(height: 10),
            Column(
              children: points.map((point) => Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.circle, size: 8, color: Colors.teal),
                    SizedBox(width: 8),
                    Expanded(child: Text(point)),
                  ],
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableInfo({required String title, required String content}) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.teal[800],
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              content,
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonalTips() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSeasonalItem(
              season: 'Summer',
              tips: [
                'Stay hydrated with water and electrolytes',
                'Use sunscreen (SPF 30+) when outdoors',
                'Wear light, breathable clothing',
                'Avoid peak sun hours (10am-4pm)',
                'Be aware of heat exhaustion symptoms'
              ],
              icon: FontAwesomeIcons.sun,
            ),
            const Divider(), // Added const for optimization
            _buildSeasonalItem(
              season: 'Winter',
              tips: [
                'Get flu vaccination if recommended',
                'Moisturize skin to prevent dryness',
                'Dress in layers to maintain body heat',
                'Wash hands frequently to prevent illness',
                'Ensure proper home ventilation'
              ],
              icon: FontAwesomeIcons.snowflake,
            ),
          ],
        ),
      ),
    );
  }

// Example _buildSeasonalItem function (if not already implemented)
  Widget _buildSeasonalItem({required String season, required List<String> tips, required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 24, color: Colors.teal),
            const SizedBox(width: 8),
            Text(
              season,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: tips.map((tip) => Text('• $tip', style: const TextStyle(fontSize: 14))).toList(),
        ),
      ],
    );
  }

  Widget _buildEmergencyCard() {
    return Card(
      color: Colors.teal[100],
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Important Emergency Numbers',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.teal[900],
              ),
            ),
            SizedBox(height: 12),
            _buildEmergencyNumber(
              title: 'Medical Emergency',
              number: '911 (or local equivalent)',
              icon: Icons.emergency,
            ),
            _buildEmergencyNumber(
              title: 'Poison Control',
              number: '1-800-222-1222 (US)',
              icon: Icons.warning,
            ),
            _buildEmergencyNumber(
              title: 'Mental Health Crisis',
              number: '988 (US Suicide Prevention)',
              icon: Icons.psychology,
            ),
            SizedBox(height: 10),
            Text(
              'Note: Store emergency contacts in your phone and keep a printed copy at home.',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyNumber({
    required String title,
    required String number,
    required IconData icon,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.teal[700]),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.teal[800],
                ),
              ),
              Text(
                number,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[900],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}