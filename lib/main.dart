import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class Article {
  final String url;
  final String title;
  final String price;
  final String urlImage;
  final String siteName;

  const Article({
    required this.url,
    required this.title,
    required this.price,
    required this.urlImage,
    required this.siteName,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.green,
        useMaterial3: true,
      ),
      home: const SearchPage(),
    );
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<Article> articles = [];
  bool _isSearching = false;
  bool _isLoadingMore = false;
  int _currentPage = 1;

  Future<void> getArticles(String query) async {
    setState(() {
      articles.clear();
      _isSearching = true;
    });

    final List<Map<String, String>> websites = [
      {
        "name": "Zettabyte",
        "url": "https://tienda.zettabyte.com.ec/1114/search?q=$query",
        "cardSelector": "div.aiz-cardSelector-box",
        "titleSelector": "h3.fw-600.fs-13.text-truncate-2 a",
        "imgSelector": "img.img-fit",
        "priceSelector": "span.fw-700",
        // Unique Price
      },
      {
        "name": "Tecnogame",
        "url": "https://tecnogame.ec/?s=$query&post_type=product",
        "cardSelector": "li.product", // Selector de la card del producto
        "titleSelector":
            ".woocommerce-loop-product__title a", // Selector del título corregido
        "imgSelector":
            "img.attachment-woocommerce_thumbnail", // Selector de la imagen
        "priceSelector": "span.price", // Contenedor principal de precios
        "discountPriceSelector":
            "ins .woocommerce-Price-amount bdi", // Selector de precio con descuento corregido
        "originalPriceSelector":
            "del .woocommerce-Price-amount bdi", // Selector de precio original corregido
      },
      {
        "name": "Masternet",
        "url":
            "https://masternet.ec/?product_cat=0&s=$query&post_type=product&et_search=true",
        "cardSelector":
            "div.content-product", // Selector de la card del producto
        "titleSelector":
            "h2.product-title a", // Selector del título del producto
        "imgSelector":
            "img.attachment-woocommerce_thumbnail", // Selector de la imagen del producto
        "priceSelector": "span.price", // Contenedor principal de precios
        "discountPriceSelector":
            "ins .woocommerce-Price-amount bdi", // Selector de precio con descuento
        "originalPriceSelector":
            "del .woocommerce-Price-amount bdi", // Selector de precio original
      },
      {
        "name": "Repuestos Laptop",
        "url": "https://www.repuestoslaptop.com.ec/families/?keywords=$query",
        "cardSelector":
            "div.product-shortcode", // Selector de la card del producto
        "titleSelector":
            "div.h6.animate-to-green a", // Selector del título del producto
        "imgSelector": "img.img-observer", // Selector de la imagen del producto
        "priceSelector":
            "div.simple-article.show-iva span.color" // Selector de precio visible
      },
      {
        "name": "MTEC",
        "url":
            "https://www.mtec-ec.com/?s=$query&post_type=product&dgwt_wcas=1",
        "cardSelector": "li.product", // Selector de la card del producto
        "titleSelector":
            "h2.woocommerce-loop-product__title", // Selector del título del producto corregido
        "imgSelector":
            "img.attachment-woocommerce_thumbnail", // Selector de la imagen del producto
        "priceSelector": "span.price", // Selector del contenedor de precios
        "discountPriceSelector":
            "ins .woocommerce-Price-amount bdi", // Selector del precio con descuento
        "originalPriceSelector":
            "del .woocommerce-Price-amount bdi" // Selector del precio original
      },
      {
        "name": "Tecnobyte",
        "url":
            "https://tecnobytesec.com/?s=$query&post_type=product&dgwt_wcas=1",
        "cardSelector": "li.product", // Selector de la card del producto
        "titleSelector":
            "h2.woocommerce-loop-product__title", // Selector del título del producto corregido
        "imgSelector":
            "img.attachment-woocommerce_thumbnail", // Selector de la imagen del producto
        "priceSelector":
            "span.woocommerce-Price-amount bdi" // Selector del precio (solo uno)
      },
      {
        "name": "Tecnomall",
        "url":
            "https://tecnobytesec.com/?s=$query&post_type=product&dgwt_wcas=1",
        "cardSelector": "li.product", // Selector de la card del producto
        "titleSelector":
            "h2.woocommerce-loop-product__title", // Selector del título del producto corregido
        "imgSelector":
            "img.attachment-woocommerce_thumbnail", // Selector de la imagen del producto
        "priceSelector":
            "span.electro-price", // Selector del contenedor de precios
        "discountPriceSelector":
            "ins .woocommerce-Price-amount bdi", // Selector del precio de descuento
        "originalPriceSelector":
            "del .woocommerce-Price-amount bdi" // Selector del precio original
      },
      {
        "name": "ABC Laptops",
        "url": "https://abclaptops.com/?s=$query&post_type=product",
        "cardSelector": "div.thunk-product", // Selector de la card del producto
        "titleSelector":
            "h2.woocommerce-loop-product__title", // Selector del título del producto corregido
        "imgSelector":
            "img.attachment-woocommerce_thumbnail", // Selector de la imagen del producto
        "priceSelector": "span.price", // Selector del contenedor de precios
        "discountPriceSelector":
            "del .woocommerce-Price-amount bdi", // Selector del precio original
        "originalPriceSelector":
            "ins .woocommerce-Price-amount bdi" // Selector del precio con descuento
      },
      {
        "name": "ClicGi",
        "url": "https://clicgi.com/?s=$query",
        "cardSelector": "div.ht-product-inner",
        "titleSelector": "h4.ht-product-titleSelector a",
        "imgSelector": "img.attachment-large"
        // Prices in the article page
      },
      {
        "name": "IDC Mayoristas",
        "url":
            "https://www.idcmayoristas.com/?s=$query&post_type=product&dgwt_wcas=1",
        "cardSelector": "div.product",
        "titleSelector": ".jet-woo-builder-archive-product-titleSelector a",
        "imgSelector": "picture.attachment-woocommerce_thumbnail img",
        "priceSelector": "span.woocommerce-Price-amount bdi"
      },
    ];

    for (var site in websites) {
      try {
        final response = await http.get(Uri.parse(site["url"]!));
        if (response.statusCode != 200) {
          print('Error: ${response.statusCode} for ${site["name"]}');
          continue;
        }

        dom.Document html = dom.Document.html(response.body);
        final cards = html.querySelectorAll(site["cardSelector"]!);

        for (var card in cards) {
          final titleElement = card.querySelector(site["titleSelector"]!);
          final urlElement = card.querySelector(site["titleSelector"]!);
          final imageElement = card.querySelector(site["imgSelector"]!);
          final priceElement = card.querySelector(site["priceSelector"]!);
          final discountPriceElement =
              card.querySelector(site["discountPriceSelector"]!);
          final originalPriceElement =
              card.querySelector(site["originalPriceSelector"]!);

          if (titleElement != null &&
              imageElement != null &&
              priceElement != null &&
              urlElement != null) {
            final title = titleElement.text.trim();
            final url = urlElement.attributes["href"] ?? "";
            final imageUrl = imageElement.attributes["src"] ?? "";

            String price = '';
            if (discountPriceElement != null) {
              price = discountPriceElement.text.trim();
            } else if (originalPriceElement != null) {
              price = originalPriceElement.text.trim();
            } else {
              price = priceElement.text.trim(); // Precio sin descuento
            }

            // Filtra precios no deseados
            if (price != '\$0,00' && price != '\$0.00') {
              setState(() {
                articles.add(Article(
                  url: url,
                  title: title,
                  price: price,
                  urlImage: imageUrl,
                  siteName: site["name"]!,
                ));
              });
            }
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error fetching data: $e'),
        ));
      }
    }
    setState(() {
      _isSearching =
          false; // Detener el indicador de carga cuando se hayan cargado los productos
    });
  }

  Future<void> _loadMoreArticles(String query) async {
    if (_isLoadingMore) return; // Evita múltiples llamadas simultáneas

    setState(() {
      _isLoadingMore = true;
    });

    // Incrementa la página o cualquier otro mecanismo de paginación que tengas
    _currentPage++;

    // Llama a getArticles o la función que maneje la carga paginada
    await getArticles(query);

    setState(() {
      _isLoadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isSearching || articles.isNotEmpty
          ? AppBar(
              title:
                  buildSearchBar(), // Muestra la barra de búsqueda en el AppBar cuando se está buscando o hay resultados
            )
          : null, // No muestra el AppBar inicialmente
      body: LayoutBuilder(
        builder: (context, constraints) {
          return _isSearching
              ? const Center(
                  child:
                      CircularProgressIndicator(), // Muestra un indicador de carga mientras se buscan los productos
                )
              : articles.isNotEmpty
                  ? buildArticleGrid(
                      constraints) // Muestra el grid de artículos cuando hay resultados
                  : buildInitialView(); // Muestra la vista inicial cuando no hay resultados
        },
      ),
    );
  }

  Widget buildInitialView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 100),
        const Image(
          image: AssetImage("assets/logo.png"),
          height: 200,
        ),
        const SizedBox(height: 50),
        buildSearchBar(), // Barra de búsqueda inicial en el centro
      ],
    );
  }

  Widget buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            onPressed: _controller.clear,
            icon: const Icon(Icons.clear),
          ),
          hintText: 'Buscar productos...',
        ),
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            getArticles(value);
          }
        },
      ),
    );
  }

  Widget buildArticleGrid(BoxConstraints constraints) {
    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: constraints.maxWidth > 800 ? 4 : 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 0.75,
      ),
      itemCount: articles.length + 1,
      itemBuilder: (context, index) {
        if (index == articles.length) {
          return _isLoadingMore
              ? const Center(
                  child:
                      CircularProgressIndicator()) // Indicador de carga al final de la lista
              : Container(); // Espacio vacío si no está cargando más
        }
        return buildArticleCard(articles[index]);
      },
    );
  }

  Widget buildArticleCard(Article article) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: FadeInImage(
              placeholder: const AssetImage('assets/placeholder.png'),
              image: NetworkImage(article.urlImage),
              fit: BoxFit.contain,
              width: double.infinity,
              imageErrorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.broken_image,
                  size: 50,
                  color: Colors.red,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              article.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(article.price),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              "Sitio: ${article.siteName}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                _launchURL(article.url);
              },
              child: const Text('Ver Producto'),
            ),
          ),
        ],
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'No se pudo abrir la URL: $url';
    }
  }
}
