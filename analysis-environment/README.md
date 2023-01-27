# Examples Python Azure SDK

In order to obtain data from a storage account, the Python Azure SDK needs to be used. 
In order to get access in a terminal, you need to be logged in:

```
az login
```

Here you can find some common code examples: 

```python
from azure.identity import DefaultAzureCredential
from azure.storage.blob import ContainerClient, BlobServiceClient

STORAGE_ACCOUNT = "d3ipilotanalysisserversa"
CONTAINER = "my-test-container"
ACCOUNT_URL = f"https://{STORAGE_ACCOUNT}.blob.core.windows.net"
CREDENTIAL = DefaultAzureCredential()

# Download a specific blob
filename = "my_file.json"
blob_service_client = BlobServiceClient(ACCOUNT_URL, CREDENTIAL)
blob_client = blob_service_client.get_blob_client(CONTAINER, blob=filename)
blob_data = blob_client.download_blob().readall()

# List all blobs in a container
container_client = ContainerClient(ACCOUNT_URL, CONTAINER, credential=CREDENTIAL)
blob_list = container_client.list_blobs()
for blob in blob_list:
    print(blob.name)
    
# Convert dataframe to xlsx and upload to container
import io
import pandas as pd

data = [(1, "a"), (2, "b"), (3, "c")]
df = pd.DataFrame(data, columns=["id", "favorite_letter"])

buffer = io.BytesIO()
with pd.ExcelWriter(buffer) as writer:
    df.to_excel(writer)  
    
blob_service_client = BlobServiceClient(ACCOUNT_URL, CREDENTIAL)
blob_client = blob_service_client.get_blob_client(CONTAINER, blob="my_dataset.xlsx")
blob_client.upload_blob(buffer.getvalue(), overwrite=True)
```
