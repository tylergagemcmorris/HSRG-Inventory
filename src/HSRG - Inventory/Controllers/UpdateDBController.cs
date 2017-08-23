using System;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using System.Data.Entity;
using System.Web;
using System.Net;
using System.Web.Mvc;
using System.Threading;
using System.Threading.Tasks;
using HSRG___Inventory.Models;
using System.Reflection;
using Newtonsoft.Json;
using System.Management.Automation;
using System.Management.Automation.Runspaces;

namespace HSRG___Inventory.Controllers
{
    public class UpdateDBController : AsyncController
    {
        // GET: UpdateDB
        public static string data { get; private set; }

        public ActionResult DoWorkCompleted(string Datapoints)
        {
            data += Datapoints;
            return Content(Datapoints);

        }

        public void DoWorkAsync()
        {
            string scriptpath = Server.MapPath("~/App_Data/test.ps1");
            //string DataSourcePath = Server.MapPath("~/App_Data/InventoryDetails.sqlite3");

            
            AsyncManager.OutstandingOperations.Increment();
            RunspaceConfiguration runspaceConfiguration = RunspaceConfiguration.Create();
            Runspace runspace = RunspaceFactory.CreateRunspace(runspaceConfiguration);
            
            runspace.Open();
            RunspaceInvoke scriptInvoker = new RunspaceInvoke(runspace);
            var pipeline = runspace.CreatePipeline();
                
            Command myCommand = new Command(scriptpath);
            myCommand.Parameters.Add("SampleInterval", 1);
            myCommand.Parameters.Add("MaxSamples", 10);
            myCommand.Parameters.Add("DataSource", "abc");

            pipeline.Commands.Add(myCommand);

            pipeline.Output.DataReady += (sender, e) =>
            {
                Thread.Sleep(1);
                string test = pipeline.Output.Read().ToString();
                AsyncManager.Parameters["Datapoints"] = test;
                
                AsyncManager.Finish();
            };

            pipeline.InvokeAsync();
            pipeline.Input.Close();
            
            
        }

        public void UpdateTablesAsync(string table)
        {
            
            string scriptpath = Server.MapPath("~/App_Data/DatabaseScripts/" + table + ".ps1");
            string DataSourcePath = Server.MapPath("~/App_Data/InventoryDetails.sqlite3");
            string InventoryList = Server.MapPath("~/App_Data/Max's Computer.txt");

            AsyncManager.OutstandingOperations.Increment();
            RunspaceConfiguration runspaceConfiguration = RunspaceConfiguration.Create();
            Runspace runspace = RunspaceFactory.CreateRunspace(runspaceConfiguration);

            runspace.Open();
            RunspaceInvoke scriptInvoker = new RunspaceInvoke(runspace);
            var pipeline = runspace.CreatePipeline();

            Command myCommand = new Command(scriptpath);
            myCommand.Parameters.Add("DataSource", DataSourcePath);
            myCommand.Parameters.Add("FilePath", InventoryList);
            pipeline.Commands.Add(myCommand);

            pipeline.Output.DataReady += (sender, e) =>
            {
                Thread.Sleep(1);
                string test = pipeline.Output.Read().ToString();
                AsyncManager.Parameters["Output"] = test;
                AsyncManager.Parameters["Table"] = table;
                AsyncManager.Parameters["Time"] = DateTime.Now.ToString();

                AsyncManager.Finish();
            };

            pipeline.InvokeAsync();
            pipeline.Input.Close();
        }

        public ActionResult UpdateTablesCompleted(string Output, string Table, string Time)
        {

            return Content("Table: " + Table + "was updated on " + Time + " with output: " + Output);
        }

        public ActionResult Test()
        {
            return View("~/Views/Performance/Test.cshtml");
        }

        public String example()
        {
            return data;
        }
    }
}