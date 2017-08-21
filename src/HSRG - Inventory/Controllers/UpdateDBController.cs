using System;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using System.Data.Entity;
using System.Web;
using System.Net;
using System.Web.Mvc;
using HSRG___Inventory.Models;
using System.Reflection;
using Newtonsoft.Json;
using System.Management.Automation;
using System.Management.Automation.Runspaces;

namespace HSRG___Inventory.Controllers
{
    public class UpdateDBController : Controller
    {
        // GET: UpdateDB
        public ActionResult Index()
        {
            // Add the script to the PowerShell object
            string path = Server.MapPath("~/App_Data/test.ps1");
            //string DataSourcePath = Server.MapPath("~/App_Data/InventoryDetails.sqlite3");

            RunspaceConfiguration runspaceConfiguration = RunspaceConfiguration.Create();

            Runspace runspace = RunspaceFactory.CreateRunspace(runspaceConfiguration);
            runspace.Open();

            RunspaceInvoke scriptInvoker = new RunspaceInvoke(runspace);

            Pipeline pipeline = runspace.CreatePipeline();

            //Here's how you add a new script with arguments
            Command myCommand = new Command(path);
            myCommand.Parameters.Add("SampleInterval", 1);
            myCommand.Parameters.Add("MaxSamples", 10);
            myCommand.Parameters.Add("DataSource", "abc");

            pipeline.Commands.Add(myCommand);

            // Execute PowerShell script
            var results = pipeline.Invoke();
            var Datapoints = results[0].BaseObject;

            return View("~/Views/Performance/Test.cshtml", Datapoints);
        }
    }
}