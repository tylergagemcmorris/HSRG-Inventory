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
using System.Collections.ObjectModel;
using System.ComponentModel;

namespace HSRG___Inventory.Controllers
{
    public class PipelineExecutor
    {
        /// Gets the powershell Pipeline associated with this PipelineExecutor
        public Pipeline Pipeline
        {
            get;
        }

        public delegate void DataReadyDelegate(PipelineExecutor sender, ICollection<PSObject> data);
        public delegate void DataEndDelegate(PipelineExecutor sender);
        public delegate void ErrorReadyDelegate(PipelineExecutor sender, ICollection<object> data);

        /// Occurs when there is new data available from the powershell script.
        public event DataReadyDelegate OnDataReady;

        /// Occurs when powershell script completed its execution.
        public event DataEndDelegate OnDataEnd;

        /// Occurs when there is error data available.
        public event ErrorReadyDelegate OnErrorRead;

        /// Constructor, creates a new PipelineExecutor for the given powershell script.
        public PipelineExecutor (Runspace runSpace, ISynchronizeInvoke invoker, string command)
        {

        }

        /// Start executing the script in the background.
        public void Start()
        {

        }

        /// Stop executing the script.
        public void Stop()
        {

        }
    }

    public class UpdateDBController2 : Controller, ISynchronizeInvoke
    {
        public bool InvokeRequired => throw new NotImplementedException();

        public IAsyncResult BeginInvoke(Delegate method, object[] args)
        {
            throw new NotImplementedException();
        }

        public object EndInvoke(IAsyncResult result)
        {
            throw new NotImplementedException();
        }

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
            
                Command myCommand = new Command(path);
                myCommand.Parameters.Add("SampleInterval", 1);
                myCommand.Parameters.Add("MaxSamples", 10);
                myCommand.Parameters.Add("DataSource", "abc");

                pipeline.Commands.Add(myCommand);
            ViewBag.Datapoints = pipeline.Invoke(); // InvokeAsync calls it as a background process so it won't make the web page timeout.

            PipelineExecutor pipelineExecutor = new PipelineExecutor(runspace, this, myCommand.CommandText);

            // listen for new data
            //pipelineExecutor.OnDataReady += new PipelineExecutor.DataReadyDelegate(pipelineExecutor_OnDataReady);

            // listen for end of data
            //pipelineExecutor.OnDataEnd += new PipelineExecutor.DataEndDelegate(pipelineExecutor_OnDataEnd);

            // launch the script
            pipelineExecutor.Start();

            return View("~/Views/Performance/Test.cshtml");
        }

        public object Invoke(Delegate method, object[] args)
        {
            throw new NotImplementedException();
        }
    }
}