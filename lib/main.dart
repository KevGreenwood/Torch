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
  final String siteName; // Nuevo campo para el nombre del sitio

  const Article({
    required this.url,
    required this.title,
    required this.price,
    required this.urlImage,
    required this.siteName, // Añadido al constructor
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

  Future<void> getArticles(String query) async {
    setState(() {
      articles.clear(); // Limpiar los artículos antes de una nueva búsqueda
    });

    final List<Map<String, String>> websites = [
      /*{
        "name": "Zettabyte",
        "url": "https://tienda.zettabyte.com.ec/1114/search?q=$query",
        "selector": "h3.fw-600.fs-13.text-truncate-2 a",
        "imgsrc": "img.img-fit"
      },
      {
        "name": "Tecnogame",
        "url": "https://tecnogame.ec/?s=$query&post_type=product",
        "selector": ".woocommerce-loop-product__title a",
        "imgsrc": "img.attachment-woocommerce_thumbnail",
        "price": "span.woocommerce-Price-amount bdi"
      },*/
      {
        "name": "Masternet",
        "url":
            "https://masternet.ec/?product_cat=0&s=$query&post_type=product&et_search=true",
        "selector": "h2.product-title a",
        "imgsrc": "img.attachment-woocommerce_thumbnail",
        "price": "span.woocommerce-Price-amount bdi"
      },
      {
        "name": "Repuestos Laptop",
        "url": "https://www.repuestoslaptop.com.ec/families/?keywords=$query",
        "selector": "div.h6.animate-to-green a",
        "imgsrc": "img.img-observer",
        "price": "span.color"
      },
      /*{
        "name": "MTEC",
        "url":
            "https://www.mtec-ec.com/?s=$query&post_type=product&dgwt_wcas=1",
        "selector": "h2.woocommerce-loop-product__title",
        "imgsrc": "img.attachment-woocommerce_thumbnail",
        "price": "span.woocommerce-Price-amount bdi"
      },*/
      {
        "name": "Tecnobyte",
        "url":
            "https://tecnobytesec.com/?s=$query&post_type=product&dgwt_wcas=1",
        "selector": "h2.woocommerce-loop-product__title",
        "imgsrc": "img.attachment-woocommerce_thumbnail",
        "price": "span.woocommerce-Price-amount bdi"
      },
      {
        "name": "Tecnomall",
        "url":
            "https://tecnobytesec.com/?s=$query&post_type=product&dgwt_wcas=1",
        "selector": "h2.woocommerce-loop-product__title",
        "imgsrc": "img.attachment-woocommerce_thumbnail",
        "price": "span.woocommerce-Price-amount bdi"
      },
      {
        "name": "ABC Laptops",
        "url": "https://abclaptops.com/?s=$query&post_type=product",
        "selector": "h2.woocommerce-loop-product__title",
        "imgsrc": "img.attachment-woocommerce_thumbnail",
        "price": "span.woocommerce-Price-amount bdi"
      },
      /*{
        "name": "ClicGi",
        "url": "https://clicgi.com/?s=$query",
        "selector": "h4.ht-product-title a",
        "imgsrc": "img.attachment-large"
      },*/
      {
        "name": "IDC Mayoristas",
        "url":
            "https://www.idcmayoristas.com/?s=$query&post_type=product&dgwt_wcas=1",
        "selector": ".jet-woo-builder-archive-product-title a",
        "imgsrc": "picture.attachment-woocommerce_thumbnail img",
        "price": "span.woocommerce-Price-amount bdi"
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
        final titles = html
            .querySelectorAll(site["selector"]!)
            .map((element) => element.innerHtml.trim())
            .toList();

        final urlImages = html
            .querySelectorAll(site["imgsrc"]!)
            .map((element) => element.attributes["src"]!)
            .where((url) => url.startsWith('https://'))
            .toList();

        final prices = html
            .querySelectorAll(site["price"]!)
            .map((element) => element.text.trim())
            .where((price) =>
                price != '\$0,00' &&
                price != '\$0.00') // Filtra los precios no deseados
            .toList();

        print("${site["name"]!}\nCount: ${titles.length}");

        setState(() {
          articles.addAll(List.generate(
            titles.length,
            (index) => Article(
              url: "", // Aquí puedes añadir la lógica para obtener la URL
              title: titles[index],
              price: prices[index], // Precio
              urlImage: urlImages[index], // Imagen
              siteName: site["name"]!, // Nombre del sitio
            ),
          ));
        });
      } catch (e) {
        SnackBar(
          content: Text('$e'),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("Torch"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), prefixIcon: Icon(Icons.search)),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  getArticles(value);
                }
              },
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(10.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Número de columnas en la cuadrícula
                  crossAxisSpacing: 10.0, // Espaciado horizontal
                  mainAxisSpacing: 10.0, // Espaciado vertical
                  childAspectRatio: 0.7, // Proporción del tamaño del hijo
                ),
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  final article = articles[index];
                  return Card(
                    elevation: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: FadeInImage(
                            placeholder: const AssetImage(
                                'assets/placeholder.png'), // Agrega una imagen de marcador de posición en los assets
                            image: NetworkImage(article.urlImage),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            imageErrorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.broken_image,
                                size: 50,
                                color: Colors.red,
                              ); // Muestra un ícono si la imagen no puede cargarse
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
                },
              ),
            ),
          ],
        ),
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
