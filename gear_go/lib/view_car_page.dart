import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'car_data_model.dart';
import 'location_set_page.dart';

class ViewCarPage extends StatefulWidget {
  final CarDataModel carData;

  const ViewCarPage({Key? key, required this.carData}) : super(key: key);

  @override
  _ViewCarPageState createState() => _ViewCarPageState();
}

class _ViewCarPageState extends State<ViewCarPage> {
  final PageController _pageController = PageController();
  int currentIndex = 0;
  bool _isImageLoading = false;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        currentIndex = _pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Matching LocationSetPage
      appBar: AppBar(
        backgroundColor: Colors.blue[800], // Matching LocationSetPage
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Car Details',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0), // Matching LocationSetPage padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageCarousel(),
                    SizedBox(height: 16),
                    _buildCarInfo(),
                    SizedBox(height: 16),
                    FeatureCar(carData: widget.carData),
                  ],
                ),
              ),
            ),
          ),
          _buildNextButton(),
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        height: 250,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: 4,
                itemBuilder: (context, index) {
                  String imageUrl;
                  switch (index) {
                    case 0:
                      imageUrl = widget.carData.carImage1;
                      break;
                    case 1:
                      imageUrl = widget.carData.carImage2;
                      break;
                    case 2:
                      imageUrl = widget.carData.carImage3;
                      break;
                    case 3:
                      imageUrl = widget.carData.carImage4;
                      break;
                    default:
                      imageUrl = '';
                  }
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_isImageLoading)
                          LoadingAnimationWidget.dotsTriangle(
                            color: Colors.blue[700]!, // Matching color
                            size: 50,
                          ),
                        Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          loadingBuilder: (
                              BuildContext context,
                              Widget child,
                              ImageChunkEvent? loadingProgress,
                              ) {
                            if (loadingProgress == null) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) setState(() => _isImageLoading = false);
                              });
                              return child;
                            }
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) setState(() => _isImageLoading = true);
                            });
                            return SizedBox.shrink();
                          },
                          errorBuilder: (context, error, stackTrace) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) setState(() => _isImageLoading = false);
                            });
                            return Center(child: Icon(Icons.error, color: Colors.red));
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            SmoothPageIndicator(
              controller: _pageController,
              count: 4,
              effect: ExpandingDotsEffect(
                activeDotColor: Colors.blue[700]!, // Matching color
                dotHeight: 10,
                dotWidth: 10,
                spacing: 8,
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildCarInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          maxLines: 2,
          widget.carData.carName,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue[900], // Matching color
          ),
        ),
        Text(
          "Brand : " + widget.carData.carBrand,
          style: GoogleFonts.poppins(
            fontSize: 19,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 8),
        Text(
          'This car delivers precision handling and unmatched excitement on the road.',
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800]),
        ),
      ],
    );
  }

  Widget _buildNextButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LocationSetPage(documentId: widget.carData.documentId),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[700], // Matching LocationSetPage
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
        ),
        child: Text(
          'NEXT',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class FeatureCar extends StatelessWidget {
  final CarDataModel carData;

  const FeatureCar({Key? key, required this.carData}) : super(key: key);

  String _truncateFeature(String feature) {
    const int maxFeatureLength = 15;
    if (feature.length <= maxFeatureLength) return feature;
    return '${feature.substring(0, maxFeatureLength)}...';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Features',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900], // Matching color
              ),
            ),
            SizedBox(height: 12),
            _buildFeatureGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    List<String> dbFeatures = [
      carData.features1,
      carData.features2,
      carData.features3,
      carData.features4,
      carData.features5,
      carData.features6,
    ];

    List<String> staticFeatures = [
      'Airbags',
      'Reverse Camera',
      'Spare Tyre',
      'Integrated LED Screen',
      'Climate Control',
      'Music System',
    ];

    List<String> allFeatures = dbFeatures + staticFeatures;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue[200]!), // Matching border color
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 4,
          crossAxisSpacing: 1,
          mainAxisSpacing: 1,
        ),
        itemCount: allFeatures.length,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              border: Border(
                right: index % 2 == 0 ? BorderSide(color: Colors.blue[200]!) : BorderSide.none,
                bottom: index < allFeatures.length - 2 ? BorderSide(color: Colors.blue[200]!) : BorderSide.none,
              ),
            ),
            child: Row(
              children: [
                SizedBox(width: 10),
                Icon(Icons.check_circle, color: Colors.blue[700], size: 16), // Matching color
                SizedBox(width: 4),
                Flexible(
                  child: Text(
                    _truncateFeature(allFeatures[index]),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}