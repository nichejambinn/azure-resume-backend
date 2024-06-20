import azure.functions as func
import logging

app = func.FunctionApp(http_auth_level=func.AuthLevel.ANONYMOUS)

@app.route(route="inc_visitors", methods=["POST"])
@app.cosmos_db_input(arg_name="documents", 
                     database_name="ResumeDB",
                     container_name="Counters",
                     id="Visitors",
                     partition_key="1",
                     connection="MyAccount_COSMOSDB")
@app.cosmos_db_output(arg_name="outputDocument", 
                      database_name="ResumeDB",
                      container_name="Counters",
                      connection="MyAccount_COSMOSDB")
def inc_visitors(req: func.HttpRequest, documents: func.DocumentList, outputDocument: func.Out[func.Document]) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    document = documents[0]
    if not document:
        return func.HttpResponse("Document not found.", status_code=404)

    if "count" in document:
        document["count"] += 1
    else:
        document["count"] = 1

    outputDocument.set(document)

    return func.HttpResponse(f"{document['count']}", status_code=200)
