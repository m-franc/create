// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

import BottomMenuController from "./bottom_menu_controller";
application.register("bottom-menu", BottomMenuController);

import ProjectMenuController from "./project_menu_controller";
application.register("project-menu", ProjectMenuController);
