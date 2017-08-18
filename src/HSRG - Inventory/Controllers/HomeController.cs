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

namespace HSRG___Inventory.Controllers
{
    public class HomeController : Controller
    {
        private Context db = new Context("InventoryDetails");

        public ActionResult Index(string TypeFilter, string SortBy, string searchitem)
        {
            PropertyInfo[] properties = typeof(HSRG___Inventory.Models.InventoryDetail).GetProperties();
            ViewBag.properties = properties;

            ViewBag.SortBy = SortBy;
            ViewBag.ShowType = TypeFilter;
            var details = from s in db.InventoryDetails
                          select s;
            switch (TypeFilter)
            {
                case "Clients":
                    details = details.Where(s => s.Type == "Client");
                    break;
                case "Servers":
                    details = details.Where(s => s.Type == "Server");
                    break;
                default:
                    break;
            }

            if (!string.IsNullOrEmpty(searchitem))
            {
                details = details.Where(x => x.ComputerID.Contains(searchitem));
            }

            return View(details.ToList());
        }

        //[HttpPost]
        //public ActionResult Index(string searchitem)
        //{
        //    details = details.Where(s => s.ComputerID == searchitem);

        //    return View(details.ToList());
        //}


        public ActionResult Details(string id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            InventoryDetail InventoryDetails = db.InventoryDetails.Find(id);
            if (InventoryDetails == null)
            {
                return HttpNotFound();
            }

            ViewBag.id = id;

            PropertyInfo[] properties = typeof(HSRG___Inventory.Models.BIOSInformation).GetProperties();
            ViewBag.properties = properties;
            //var BIOSInfo = db.BIOSInformation.First(s => s.ComputerID == id);

            return View();
        }

        [ChildActionOnly]
        public ActionResult PartialBios(string id)
        {
            PropertyInfo[] properties = typeof(HSRG___Inventory.Models.BIOSInformation).GetProperties();
            ViewBag.properties = properties;
            ViewBag.Title = "BIOS Information";

            return PartialView("~/Views/Table/BiosInformation.cshtml", db.BIOSInformation.First(s => s.ComputerID == id));
        }

        [ChildActionOnly]
        public ActionResult PartialMemory(string id)
        {
            PropertyInfo[] properties = typeof(HSRG___Inventory.Models.MemoryInformation).GetProperties();
            ViewBag.properties = properties;
            ViewBag.Title = "Memory Information";

            return PartialView("~/Views/Table/MemoryInformation.cshtml", db.MemoryInformation.Where(s => s.ComputerID == id));
        }

        [ChildActionOnly]
        public ActionResult PartialSystem(string id)
        {
            PropertyInfo[] properties = typeof(HSRG___Inventory.Models.SystemInformation).GetProperties();
            ViewBag.properties = properties;
            ViewBag.Title = "System Information";

            return PartialView("~/Views/Table/SystemInformation.cshtml", db.SystemInformation.First(s => s.ComputerID == id));
        }

        [ChildActionOnly]
        public ActionResult PartialHardDisk(string id)
        {
            PropertyInfo[] properties = typeof(HSRG___Inventory.Models.HardDiskInformation).GetProperties();
            ViewBag.properties = properties;
            ViewBag.Title = "Hard Disk Information";

            return PartialView("~/Views/Table/HardDiskInformation.cshtml", db.HardDiskInformation.First(s => s.ComputerID == id));
        }

        [ChildActionOnly]
        public ActionResult PartialMotherBoard(string id)
        {
            PropertyInfo[] properties = typeof(HSRG___Inventory.Models.MotherBoardInformation).GetProperties();
            ViewBag.properties = properties;
            ViewBag.Title = "MotherBoard Information";

            return PartialView("~/Views/Table/MotherBoardInformation.cshtml", db.MotherBoardInformation.First(s => s.ComputerID == id));
        }

        [ChildActionOnly]
        public ActionResult PartialSystemEnclosure(string id)
        {
            PropertyInfo[] properties = typeof(HSRG___Inventory.Models.SystemEnclosure).GetProperties();
            ViewBag.properties = properties;
            ViewBag.Title = "System Enclosure";

            return PartialView("~/Views/Table/SystemEnclosure.cshtml", db.SystemEnclosure.First(s => s.ComputerID == id));
        }

        [ChildActionOnly]
        public ActionResult PartialDriveSpace(string id)
        {
            PropertyInfo[] properties = typeof(HSRG___Inventory.Models.DriveSpace).GetProperties();
            ViewBag.properties = properties;
            ViewBag.Title = "Drive Space";

            return PartialView("~/Views/Table/DriveSpace.cshtml", db.DriveSpace.Where(s => s.ComputerID == id)); //Error: Input string not in correct format
        }

        [ChildActionOnly]
        public ActionResult PartialNetwork(string id)
        {
            PropertyInfo[] properties = typeof(HSRG___Inventory.Models.NetworkAdapters).GetProperties();
            ViewBag.properties = properties;
            ViewBag.Title = "Network Adapters";

            var details = db.NetworkAdapters.Where(s => s.ComputerID == id);

            return PartialView("~/Views/Table/NetworkAdapters.cshtml", details);
        }

        [ChildActionOnly]
        public ActionResult PartialUpdates(string id)
        {
            PropertyInfo[] properties = typeof(HSRG___Inventory.Models.UpdatesInstalled).GetProperties();
            ViewBag.properties = properties;
            ViewBag.Title = "Installed Updates";

            var details = db.UpdatesInstalled.Where(s => s.ComputerID == id);

            return PartialView("~/Views/Table/UpdatesInstalled.cshtml", details);
        }

        public ActionResult Test()
        {
            ViewBag.Datapoints = JsonConvert.SerializeObject(db.UpdatesInstalled.ToList());
            return View("~/Views/Performance/Test.cshtml");
        }
    }
}