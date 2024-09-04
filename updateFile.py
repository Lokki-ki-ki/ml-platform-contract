# import the module
import shutil

# The files to update
file_to_copy = './build/contracts/MlContract.json'
file_to_copy_2 = './build/contracts/MlPlatformFactory.json'

# Copy files to off-chain oracle
oracle_directory = '/Users/lokki/Downloads/FYP/fyp_project/ml-platform-oracle/MlContract.json'
oracle_directory_2 = '/Users/lokki/Downloads/FYP/fyp_project/ml-platform-oracle/MlPlatformFactory.json'

shutil.copy(file_to_copy, oracle_directory)
shutil.copy(file_to_copy_2, oracle_directory_2)

# Frontend files paths
frontend_directory = '/Users/lokki/Downloads/FYP/fyp_project/ml-platform/src/Docs/MlContract.json'
frontend_directory_2 = '/Users/lokki/Downloads/FYP/fyp_project/ml-platform/src/Docs/MlPlatformFactory.json'

shutil.copy(file_to_copy, frontend_directory)
shutil.copy(file_to_copy_2, frontend_directory_2)

