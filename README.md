# InvScan - Ashita V3 Addon for Final Fantasy XI

InvScan is a simple Ashita v3 addon for Final Fantasy XI that scans your character's inventory containers (including Safe, Storage, Locker, Sack, Satchel, Case, Wardrobes, etc.) and exports the results to a CSV file. This can be useful for tracking items, jobs that can use them, and other basic information for inventory management.

---

## Features

- **Scans multiple containers**: Inventory, Safe, Storage, Locker, Satchel, Sack, Case, and Wardrobes 1-4  
- **Exports to CSV**: Creates a CSV file named `inventory_export.csv` in the addon's folder  
- **Generates a log file**: Creates `inventory_export.log` in the addon's folder to keep track of export runs and messages  
- **Displays scan output in chat**: Shows basic details (Jobs, level, item slots, etc.) when exporting  

---

## Requirements

1. **Ashita v3** installed and working with Final Fantasy XI  
2. **FFXI Resource Manager**: Ashita already provides resource management out of the box; no extra setup is typically needed beyond Ashita’s default installation

---

## Installation

1. **Download/Clone** this repository (or copy the `invscan.lua` file).  
2. Navigate to your Ashita installation directory (for example, `C:\Program Files (x86)\Ashita\`).  
3. Within the `addons` folder (e.g., `C:\Program Files (x86)\Ashita\addons`), create a new folder named `invscan`.  
4. Place the `invscan.lua` file inside the newly created `invscan` folder:
addons
  ├── invscan │
      └── invscan.lua
  └── other_addons...

6. Start (or restart) Ashita v3 and launch Final Fantasy XI with Ashita.  

---

## Usage

1. **Load the addon**  
- Once you are in-game, the InvScan addon should load automatically if placed correctly in the `addons` folder. You should see a message in the Ashita console or chat log indicating:  
  ```
  [invscan] invscan addon loaded. Default export folder: ...
  ```

2. **Run the scan**  
- Open the FFXI chat window and type:
  ```
  /invscan run
  ```
- This will scan all the supported containers and export the results to a CSV file.

3. **Check the output**  
- **CSV File**: A file named `inventory_export.csv` will be created or overwritten in your `addons\invscan` folder.  
- **Log File**: A log file named `inventory_export.log` will also be created/appended in the same folder, containing timestamps and any debug messages.

---

## Configuration

Inside the `invscan.lua` file, you can modify a few settings:

- **`export_folder`**  
By default, the CSV and log files are saved in the same folder as the addon. If you wish to change the output location, edit the `export_folder` variable.  
- **`csv_filename`**  
If you want to name the CSV file differently (e.g., `my_items.csv`), you can change this variable.  
- **Inventory Container List**  
If you need to exclude or include different containers, you can edit the `inventories` table.  
- **Job Names**  
The addon includes a list of all jobs recognized by FFXI. If new jobs are added in the future or you want to customize them, you can adjust the `job_names` table.

---

## Commands

- **`/invscan run`**  
Perform the inventory scan and export to CSV.

- **`/invscan`**  
Shows usage instructions in the chat window if no arguments are provided (other than `/invscan` itself).

---

## Troubleshooting

- **Addon not loading**  
Make sure the `invscan.lua` file is inside a folder named `invscan` located in your `addons` directory. Confirm that your `Ashita.xml` (or similar config) is set up to load addons automatically.  

- **No CSV or log file generated**  
Check that the script has permissions to write to the addon’s folder. Some installations of Windows may prevent writing to protected folders if Ashita is installed under `\Program Files (x86)\`. You can also try running Ashita as Administrator.  

- **In-game error message**  
If the addon cannot find the item resource or fails to scan a container, it may log an error in the console or `inventory_export.log`. Ensure you have the latest version of Ashita and resources are loading correctly.

---

## Contributing

If you find issues or would like to add features, feel free to open a pull request or submit an issue on the repository. Contributions are welcome!

---


**Happy scanning!** If you have any questions or problems, please open an issue or reach out. Enjoy keeping track of your FFXI items with InvScan!
