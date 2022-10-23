# Apenas cortar texto ########################################################################################################################################################################
def CuttedText():
  import os

  dir_path = os.path.dirname(os.path.realpath(__file__))
  var1 = dir_path.split('/src')
  Dir_tmp = var1[0] + '/data/tmp'

  with open(Dir_tmp + '/analysing.txt') as f:
    text = f.read()
  response = text[0:1000:1]
  return response

# OpenAI GPT-3 ########################################################################################################################################################################
def SumarizeOpenAI():
  import openai
  import os

  dir_path = os.path.dirname(os.path.realpath(__file__))
  var1 = dir_path.split('/src')
  Dir_tmp = var1[0] + '/data/tmp'
  openai.api_key = "<key_summarization_service>"

  with open(Dir_tmp + '/analysing.txt') as f:
    text = f.read()
  response = openai.Completion.create(
    model="text-davinci-002",
    prompt="Resuma isto para um estudante de ensino médio em língua portuguesa:\n"+text,
    temperature=0.95,
    max_tokens=150,
    top_p=1.0,
    frequency_penalty=0.0,
    presence_penalty=0.0
  )
  return response

# Azure extract key phrases

def Extract_key_phrases():
  # [START extract_key_phrases]
  import os


  endpoint = "<summarization_service>"
  key = "<key_summarization_service>"
  dir_path = os.path.dirname(os.path.realpath(__file__))
  var1 = dir_path.split('/src')
  Dir_tmp = var1[0] + '/data/tmp'

  with open(Dir_tmp + '/analysing.txt') as f:
    text = f.read()
  from azure.core.credentials import AzureKeyCredential
  from azure.ai.textanalytics import TextAnalyticsClient

  text_analytics_client = TextAnalyticsClient(endpoint=endpoint, credential=AzureKeyCredential(key))
  articles = [
    text
  ]

  result = text_analytics_client.extract_key_phrases(articles)
  for idx, doc in enumerate(result):
    if not doc.is_error:
      return result
  # [END extract_key_phrases]


#Summarization Azure Cognitive Services

def AzureSummarization():
    import os
    from azure.ai.textanalytics import TextAnalyticsClient
    from azure.core.credentials import AzureKeyCredential

    dir_path = os.path.dirname(os.path.realpath(__file__))
    var1 = dir_path.split('/src')
    Dir_tmp = var1[0] + '/data/tmp'

    with open(Dir_tmp + '/analysing.txt') as f:
        text = f.read()
    key = "<key_summarization_service>"
    endpoint = "<summarization_service>"

    # Authenticate the client using your key and endpoint
    def authenticate_client():
        ta_credential = AzureKeyCredential(key)
        text_analytics_client = TextAnalyticsClient(
                endpoint=endpoint,
                credential=ta_credential)
        return text_analytics_client

    client = authenticate_client()

    from azure.core.credentials import AzureKeyCredential
    from azure.ai.textanalytics import (
        TextAnalyticsClient,
        ExtractSummaryAction
    )

    document = [
        text
    ]

    poller = client.begin_analyze_actions(
        document,
        actions=[
            ExtractSummaryAction(max_sentence_count=4)
        ],
    )

    document_results = poller.result()
    for result in document_results:
        extract_summary_result = result[0]  # first document, first result
        if extract_summary_result.is_error:
            return("...Is an error with code '{}' and message '{}'".format(
                extract_summary_result.code, extract_summary_result.message
            ))
        else:
            return("{}".format(
                " ".join([sentence.text for sentence in extract_summary_result.sentences]))
            )
