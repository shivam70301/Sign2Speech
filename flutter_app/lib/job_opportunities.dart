import 'package:flutter/material.dart';

class JobOpportunitiesPage extends StatefulWidget {
  @override
  _JobOpportunitiesPageState createState() => _JobOpportunitiesPageState();
}

class _JobOpportunitiesPageState extends State<JobOpportunitiesPage> {
  List<Map<String, String>> jobs = [
    {
      "title": "Sign Language Translator",
      "company": "ABC Communications",
      "location": "Mumbai",
      "gender": "Male/Female",
      "type": "Full-time",
      "salary": "₹6,00,000/year",
      "duration": "",
      "description": "We are looking for a skilled Sign Language Translator to facilitate communication between deaf/hard-of-hearing individuals and hearing individuals in various settings. The ideal candidate should be fluent in Indian Sign Language (ISL) and have at least 2 years of professional experience.",
      "requirements": "• Fluency in Indian Sign Language (ISL)\n• 2+ years of professional experience\n• Excellent communication skills\n• Ability to work in fast-paced environments\n• Certification in Sign Language Interpretation preferred",
      "posted": "2 days ago"
    },
    {
      "title": "Remote Sign Language Interpreter",
      "company": "Global Translations",
      "location": "Remote",
      "gender": "Female",
      "type": "Part-time",
      "salary": "₹4,50,000/year",
      "duration": "",
      "description": "Provide remote sign language interpretation services for online meetings, classes, and video calls. Flexible hours available. Must have reliable high-speed internet connection and professional setup.",
      "requirements": "• Proficiency in ISL\n• 1+ year experience in remote interpreting\n• Quiet, professional workspace\n• High-speed internet connection\n• Availability for at least 20 hours/week",
      "posted": "1 week ago"
    },
    {
      "title": "Freelance ASL Interpreter",
      "company": "Freelance",
      "location": "Chennai",
      "gender": "Male",
      "type": "Freelance",
      "salary": "₹1,000/session",
      "duration": "",
      "description": "Freelance opportunities for ASL interpreters for various events including conferences, workshops, and private sessions. Sessions typically last 2-3 hours.",
      "requirements": "• ASL certification\n• Professional demeanor\n• Willingness to travel within city\n• Flexible schedule\n• Own transportation preferred",
      "posted": "3 days ago"
    },
    {
      "title": "Sign Language Instructor",
      "company": "Deaf Education Center",
      "location": "Bangalore",
      "gender": "Male/Female",
      "type": "Full-time",
      "salary": "₹5,50,000/year",
      "duration": "",
      "description": "Teach sign language to students of various ages and skill levels. Develop curriculum and teaching materials. Conduct assessments and provide feedback to students.",
      "requirements": "• 3+ years teaching experience\n• Advanced ISL proficiency\n• Curriculum development experience\n• Patience and excellent teaching skills\n• Bachelor's degree in related field preferred",
      "posted": "5 days ago"
    },
    {
      "title": "Intern - Sign Language Support",
      "company": "Startup X",
      "location": "Delhi",
      "gender": "Male/Female",
      "type": "Internship",
      "salary": "₹10,000/month",
      "duration": "3 Months",
      "description": "Internship opportunity for sign language students to gain practical experience. Assist with interpretation in office settings and community events. Mentorship provided.",
      "requirements": "• Currently enrolled in sign language program\n• Basic ISL proficiency\n• Willingness to learn\n• Good interpersonal skills\n• Minimum 20 hours/week commitment",
      "posted": "1 day ago"
    },
  ];

  String searchQuery = "";
  bool showFilters = false;
  List<String> selectedJobTypes = [];
  List<String> selectedLocations = [];
  List<String> selectedGenders = [];

  final List<String> jobTypes = ["Full-time", "Part-time", "Internship", "Freelance"];
  final List<String> locations = ["Remote", "Mumbai", "Delhi", "Bangalore", "Chennai"];
  final List<String> genderOptions = ["Male", "Female", "Male/Female"];

  List<Map<String, String>> filteredJobs = [];

  @override
  void initState() {
    super.initState();
    filteredJobs = List.from(jobs);
  }

  void applyFilters() {
    setState(() {
      filteredJobs = jobs.where((job) {
        bool matchesSearch = searchQuery.isEmpty ||
            job["title"]!.toLowerCase().contains(searchQuery.toLowerCase()) ||
            job["location"]!.toLowerCase().contains(searchQuery.toLowerCase());

        bool matchesJobType = selectedJobTypes.isEmpty || selectedJobTypes.contains(job["type"]);
        bool matchesLocation = selectedLocations.isEmpty || selectedLocations.contains(job["location"]);
        bool matchesGender = selectedGenders.isEmpty || selectedGenders.contains(job["gender"]);

        return matchesSearch && matchesJobType && matchesLocation && matchesGender;
      }).toList();

      showFilters = false;
    });
  }

  void clearFilters() {
    setState(() {
      selectedJobTypes.clear();
      selectedLocations.clear();
      selectedGenders.clear();
      searchQuery = "";
      filteredJobs = List.from(jobs);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Job Opportunities')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search Jobs...",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onChanged: (query) {
                      setState(() {
                        searchQuery = query;
                        applyFilters();
                      });
                    },
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showFilters = !showFilters;
                    });
                  },
                  child: Text(showFilters ? "Close" : "Filter"),
                ),
              ],
            ),
          ),

          if (showFilters)
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Job Type"),
                  Wrap(
                    children: jobTypes.map((type) {
                      return FilterChip(
                        label: Text(type),
                        selected: selectedJobTypes.contains(type),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedJobTypes.add(type);
                            } else {
                              selectedJobTypes.remove(type);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 10),
                  Text("Location"),
                  Wrap(
                    children: locations.map((loc) {
                      return FilterChip(
                        label: Text(loc),
                        selected: selectedLocations.contains(loc),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedLocations.add(loc);
                            } else {
                              selectedLocations.remove(loc);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 10),
                  Text("Gender"),
                  Wrap(
                    children: genderOptions.map((gender) {
                      return FilterChip(
                        label: Text(gender),
                        selected: selectedGenders.contains(gender),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedGenders.add(gender);
                            } else {
                              selectedGenders.remove(gender);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: clearFilters,
                        child: Text("Clear"),
                      ),
                      ElevatedButton(
                        onPressed: applyFilters,
                        child: Text("Apply"),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          Expanded(
            child: ListView.builder(
              itemCount: filteredJobs.length,
              itemBuilder: (context, index) {
                final job = filteredJobs[index];

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(job["title"]!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(height: 4),
                        Text(job["company"]!, style: TextStyle(color: Colors.grey[700])),
                        SizedBox(height: 8),

                        Row(
                          children: [
                            Icon(Icons.location_on, size: 16, color: Colors.grey),
                            SizedBox(width: 4),
                            Text(job["location"]!),
                          ],
                        ),

                        SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.attach_money, size: 16, color: Colors.grey),
                            SizedBox(width: 4),
                            Text(job["salary"]!),
                          ],
                        ),

                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => JobDetailsPage(job: job),
                              ),
                            );
                          },
                          child: Text("View Details"),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class JobDetailsPage extends StatelessWidget {
  final Map<String, String> job;

  JobDetailsPage({required this.job});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(job["title"]!),
        actions: [
          IconButton(
            icon: Icon(Icons.bookmark_border),
            onPressed: () {
              // Bookmark functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              job["title"]!,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              job["company"]!,
              style: TextStyle(fontSize: 18, color: Colors.blue),
            ),
            SizedBox(height: 16),

            // Job Overview
            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDetailItem(Icons.location_on, job["location"]!),
                        _buildDetailItem(Icons.work, job["type"]!),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDetailItem(Icons.attach_money, job["salary"]!),
                        _buildDetailItem(Icons.people, job["gender"]!),
                      ],
                    ),
                    if (job["duration"]!.isNotEmpty) ...[
                      SizedBox(height: 12),
                      Row(
                        children: [
                          _buildDetailItem(Icons.calendar_today, "Duration: ${job["duration"]}"),
                        ],
                      ),
                    ],
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Text("Posted ${job["posted"]}", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Job Description
            Text(
              "Job Description",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(job["description"]!),

            SizedBox(height: 24),

            // Requirements
            Text(
              "Requirements",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(job["requirements"]!),

            SizedBox(height: 32),

            // Apply Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Apply for job functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Application submitted for ${job["title"]}")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                ),
                child: Text("Apply Now"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        SizedBox(width: 4),
        Text(text),
      ],
    );
  }
}