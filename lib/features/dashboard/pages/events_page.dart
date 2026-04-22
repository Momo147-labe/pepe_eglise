import 'package:flutter/material.dart';
import 'package:eglise_labe/core/constants/colors.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildStatsGrid(),
          const SizedBox(height: 32),
          _buildFilters(),
          const SizedBox(height: 24),
          Expanded(child: _buildEventsGrid()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Événements Spéciaux",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A202C),
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Conférences, Concerts et Célébrations",
              style: TextStyle(color: Colors.black45, fontSize: 16),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => _showAddEventDialog(),
          icon: const Icon(Icons.add_rounded, size: 20),
          label: const Text("Planifier un événement"),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryOrange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            shadowColor: AppColors.primaryOrange.withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        _buildStatCard(
          "Total Événements",
          "24",
          "En 2024",
          Icons.event_available_rounded,
          Colors.blue,
        ),
        const SizedBox(width: 24),
        _buildStatCard(
          "Participants Attendus",
          "1,200",
          "Prochain Event",
          Icons.groups_rounded,
          Colors.orange,
        ),
        const SizedBox(width: 24),
        _buildStatCard(
          "Inscriptions",
          "450",
          "Conférence J.",
          Icons.app_registration_rounded,
          Colors.teal,
        ),
        const SizedBox(width: 24),
        _buildStatCard(
          "Budget Alloué",
          "15M GNF",
          "Global",
          Icons.monetization_on_rounded,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    String sub,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: Colors.black.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A202C),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    label,
                    style: const TextStyle(color: Colors.black45, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    sub,
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withOpacity(0.05)),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: "Rechercher un événement...",
                hintStyle: TextStyle(color: Colors.black26),
                border: InputBorder.none,
                icon: Icon(Icons.search, color: Colors.black26),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        _buildFilterItem(Icons.filter_list_rounded, "Statut"),
        const SizedBox(width: 12),
        _buildFilterItem(Icons.calendar_today_rounded, "Date"),
      ],
    );
  }

  Widget _buildFilterItem(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black54),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: Colors.black26,
          ),
        ],
      ),
    );
  }

  Widget _buildEventsGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: 0.85,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return _buildEventCard(index);
      },
    );
  }

  Widget _buildEventCard(int index) {
    final List<String> images = [
      'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=500&q=80',
      'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=500&q=80',
      'https://images.unsplash.com/photo-1490730141103-6ac217a94bfe?w=500&q=80',
      'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=500&q=80',
      'https://images.unsplash.com/photo-1523580494863-6f3031224c94?w=500&q=80',
      'https://images.unsplash.com/photo-1517457373958-b7bdd4587205?w=500&q=80',
    ];

    final List<String> titles = [
      "Conférence de la Jeunesse",
      "Concert de Louange Annuel",
      "Séminaire sur la Famille",
      "Fête des Moissons",
      "Retraite Spirituelle",
      "Veillée de Prière",
    ];

    final List<String> dates = [
      "15 Mai 2024",
      "22 Juin 2024",
      "10 Juillet 2024",
      "05 Août 2024",
      "12 Septembre 2024",
      "31 Décembre 2024",
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.network(
                images[index % images.length],
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 180,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.image_not_supported_rounded,
                    color: Colors.grey[400],
                  ),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 180,
                    width: double.infinity,
                    color: Colors.grey[100],
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
              ),
              Position8(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "À venir",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titles[index % titles.length],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A202C),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: Colors.black26,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dates[index % dates.length],
                      style: const TextStyle(
                        color: Colors.black45,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 14,
                      color: Colors.black26,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Grand Sanctuaire, Labé",
                      style: TextStyle(color: Colors.black45, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.people_rounded,
                          size: 16,
                          color: AppColors.primaryOrange,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "120 inscrits",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryOrange,
                          ),
                        ),
                      ],
                    ),
                    TextButton(onPressed: () {}, child: const Text("Détails")),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEventDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Planifier un événement"),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPlaceholderImagePicker(),
                const SizedBox(height: 24),
                _buildTextField("Titre de l'événement", Icons.title_rounded),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        "Date",
                        Icons.calendar_today_rounded,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        "Heure",
                        Icons.access_time_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField("Lieu", Icons.location_on_rounded),
                const SizedBox(height: 16),
                _buildTextField(
                  "Description",
                  Icons.description_rounded,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Planifier"),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImagePicker() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.black.withOpacity(0.05),
          style: BorderStyle.none,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.add_photo_alternate_rounded,
            size: 40,
            color: Colors.black26,
          ),
          const SizedBox(height: 8),
          const Text(
            "Ajouter une image de couverture",
            style: TextStyle(color: Colors.black26),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, {int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryOrange),
        ),
      ),
    );
  }
}

class Position8 extends StatelessWidget {
  final double? top;
  final double? right;
  final Widget child;
  const Position8({super.key, this.top, this.right, required this.child});
  @override
  Widget build(BuildContext context) {
    return Positioned(top: top, right: right, child: child);
  }
}
