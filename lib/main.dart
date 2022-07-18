import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void main() async {
  await initHiveForFlutter();
  runApp(const MyApp());
}

String getAllParent = """
  query MyQuery {
  user_parent {
    email
    id
    name
    password
  }
}
""";

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final HttpLink httpLink = HttpLink(
        'https://probable-dodo-81.hasura.app/v1/graphql',
        defaultHeaders: {
          "content-type": "application/json",
          "x-hasura-admin-secret":
              "sM7NjJiUKQqmBJLxvOUxeyRvezJWRhQV5f7PzsCHtJoXUJjYowUfnEa5H25mlLOh",
        });
    ValueNotifier<GraphQLClient> client = ValueNotifier(
      GraphQLClient(
        link: httpLink,
        // The default store is the InMemoryStore, which does NOT persist to disk
        cache: GraphQLCache(store: HiveStore()),
      ),
    );
    return GraphQLProvider(
      client: client,
      child: MaterialApp(
        title: 'Flutter Demo',
        home: Scaffold(
          body: SafeArea(
            child: Query(
                options: QueryOptions(document: gql(getAllParent)),
                builder: (QueryResult result,
                    {VoidCallback? refetch, FetchMore? fetchMore}) {
                  if (result.hasException) {
                    return Text(result.exception.toString());
                  }

                  print(result.data);

                  if (result.isLoading) {
                    return const Text('Loading');
                  }

                  List? repositories = result.data?['user_parent'];

                  if (repositories == null) {
                    return const Text('No repositories');
                  }

                  return ListView.builder(
                      itemCount: repositories.length,
                      itemBuilder: (context, index) {
                        final repository = repositories[index];

                        return Column(
                          children: [
                            Text(repository['email'] ?? ''),
                            Text(repository['name'] ?? ''),
                            Text("======"),
                          ],
                        );
                      });
                }),
          ),
        ),
      ),
    );
  }
}
