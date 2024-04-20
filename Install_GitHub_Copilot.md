# Install GitHub Copilot

## Install Visual Studio Code

1. Download and Install [VSCodeUserSetup-x64-1.88.1.exe](https://code.visualstudio.com/Download)
2. Press the `Extensions` icon (Ctrl+Shift+X) and search for `SQL Server (mssql)`. Press Install.
3. Press the `SQL Server` icon (Ctrl+Alt+D) and let it install.
4. Press `Add Connection` under `CONNECTIONS`.
5. Give the SQL Server (e.x. `W0000NNNNN\EDW`).
6. For `Database` leave it empty and press Enter.
7. For `Authentication Type` choose `Integrated`.
8. For `Display name` leave it empty and press Enter.
9. Press the `Enable Trust Server Certificate` button.
10. Now every time you open VS Code, you will find all your servers (in connection panel) in disconnected state.
11. Open Databases>EDW>Tables, right-click on a table, and select top 1000. The query will appear, and on the right you’ll see the results. Press on the top-right corner the icon `Save as CSV` then press to install `Rainbow CSV`.
12. On top press the Search bar and type `settings.json`. Then copy and paste the following code:
```
    ,
    "mssql.saveAsCsv": {
        "delimiter": ";"
    }
```
13. Press the `Extensions` icon (Ctrl+Shift+X) and search for `GitHub Copilot`. Press Install.
14. On the buttom-right corner press `Sign in to GitHub`, then press `Allow`.
15. Login to GitHub and press `Authorise Visual Studio Code`.

