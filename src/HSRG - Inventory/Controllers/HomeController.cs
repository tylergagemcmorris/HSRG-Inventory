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

namespace HSRG___Inventory.Controllers
{
    public class HomeController : Controller
    {
        private Context db = new Context("InventoryDetails");

        public ActionResult Index()
        {
            PropertyInfo[] properties = typeof(HSRG___Inventory.Models.InventoryDetail).GetProperties();
            ViewBag.properties = properties;
            return View(db.InventoryDetails.ToList());
        }

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
            return View(InventoryDetails);
        }
    }
}