class Category{
  String name;
  String imageURL;
  Category(this.name, this.imageURL);
}

/*Widget displayCategory(Category category){
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:[
            Colors.grey.shade200,
            Colors.teal.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.3,0.9]
        ), 
            borderRadius: BorderRadius.circular(15)
      ),
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 20, top: 10, bottom: 5),
            child: Text(category.name, style: TextStyle(color: Colors.grey[800], fontSize: 16, fontWeight: FontWeight.bold),),
          ),
          Expanded(
            child: Padding(
            padding: EdgeInsets.only(left: 20, top:5, bottom:20, right: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(category.imageURL, fit:BoxFit.cover)
              ),
            )
          )
        ],
      )
    );
  }

  Widget displayGrid(){
    return Container(
      height: 200, 
      child: GridView.count(
        padding: EdgeInsets.all(20),
        childAspectRatio: 5/2,
        mainAxisSpacing: 10,
        children: displayListOfCategories(),
        crossAxisCount: 1,
      ),
    );
  }

  List<Widget> displayListOfCategories(){
    List<Category> categoryList = CategoryOperations.getCategories();//Receive Data
    // Convert Data to Widget using Map function
    List<Widget> categories = categoryList.map((Category category)=>displayCategory(category)).toList();
    return categories;
  }*/