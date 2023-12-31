module Components.Accordion exposing
    ( Builder, default
    , withClassName
    , DisplaySize(..), withDisplaySize
    , withHeadingLevel
    , withBorder
    , withAttribute, setAttributes
    , withAccordionItem, setAccordionItems
    , toHtml
    )

{-| An **accordion** is an interactive container that expands and
collapses to hide or reveal nested content. It takes advantage of
progressive disclosure to help reduce page scrolling, by allowing
users to choose whether they want to show or hide more detailed
information as needed.

This is based on the Patternfly-React accordian. For more information,
see [here](https://www.patternfly.org/v4/components/accordion).


# Accordions


# Builder

@docs Builder, default


# Class name

@docs withClassName


# Display size

@docs DisplaySize, withDisplaySize


# Heading level

The "HeadingLevel" type can be found in Components.Accordion.Types.

@docs withHeadingLevel


# Borders

@docs withBorder


# Attributes

@docs withAttribute, setAttributes


# Accordion Items

Accordion items are containers for the contents of an accordion. The
Accordion Builder's Items are **not** HTML elements, but Accordion
Item Builders.

@docs withAccordionItem, setAccordionItems


# To HTML

@docs toHtml

-}

import Components.Accordion.Item as AccordionItem
import Components.Accordion.Types exposing (HeadingLevel(..))
import Html as H exposing (Attribute, Html)
import Html.Attributes exposing (classList)


{-| Opaque Builder type used to build a pipeline around.
-}
type Builder msg
    = Builder (Options msg)


type alias Options msg =
    { className : Maybe String
    , displaySize : DisplaySize
    , headingLevel : HeadingLevel
    , isBordered : Bool
    , accordionItems : List (AccordionItem.Builder msg)
    , attributes : List (Attribute msg)
    }


defaultOptions : Options msg
defaultOptions =
    { className = Nothing
    , displaySize = Default
    , headingLevel = DefinitionList
    , isBordered = False
    , accordionItems = []
    , attributes = []
    }


{-| The default Accordion Builder. This should be the start of a
builder pipeline.
-}
default : Builder msg
default =
    Builder defaultOptions



-- * Classname


{-| The Accordion can be given a custom class name by passing in a className
string.
-}
withClassName : String -> Builder msg -> Builder msg
withClassName string (Builder opts) =
    Builder { opts | className = Just string }



-- * Display size


{-| Display size variant.
-}
type DisplaySize
    = Default
    | Large


{-| Pipeline builder for display size.
-}
withDisplaySize : DisplaySize -> Builder msg -> Builder msg
withDisplaySize disp (Builder opts) =
    Builder { opts | displaySize = disp }


{-| Pipeline builder for the heading level.
-}
withHeadingLevel : HeadingLevel -> Builder msg -> Builder msg
withHeadingLevel level (Builder opts) =
    Builder { opts | headingLevel = level }



-- * Borders


{-| Pipeline builder to indicate if the Accordion has a border.
-}
withBorder : Bool -> Builder msg -> Builder msg
withBorder bool (Builder opts) =
    Builder { opts | isBordered = bool }



-- * Items


{-| Add an Accordion Item to the already existing accordion
items. The first Builder is an Accordion Item Builder, while the
second is an Accordion Builder. The output is an Accordion Builder.
-}
withAccordionItem :
    AccordionItem.Builder msg
    -> Builder msg
    -> Builder msg
withAccordionItem options (Builder opts) =
    Builder { opts | accordionItems = options :: opts.accordionItems }


{-| Completely override and set the Accordion Items in the
Builder. The first argument is a list of Accordion Item Builders,
while the second is an Accordion Builder. The output is an Accordion Builder.
-}
setAccordionItems : List (AccordionItem.Builder msg) -> Builder msg -> Builder msg
setAccordionItems items (Builder opts) =
    Builder { opts | accordionItems = items }



-- * Attributes


{-| Add an attribute to the Accordion HTML element.
-}
withAttribute : Attribute msg -> Builder msg -> Builder msg
withAttribute attr (Builder opts) =
    Builder { opts | attributes = attr :: opts.attributes }


{-| Set the attributes of the Accordion HTML element to be the given
list of attributes.
-}
setAttributes : List (Attribute msg) -> Builder msg -> Builder msg
setAttributes attrs (Builder opts) =
    Builder { opts | attributes = attrs }



-- * To HTML


toComponent : Builder msg -> List (Attribute msg) -> List (Html msg) -> Html msg
toComponent (Builder opts) =
    case opts.headingLevel of
        DefinitionList ->
            H.dl

        _ ->
            H.div


toClasses : Builder msg -> List ( String, Bool )
toClasses (Builder opts) =
    let
        accordion =
            ( "pf-c-accordion", True )

        isBordered =
            if opts.isBordered then
                ( "pf-m-bordered", True )

            else
                ( "", False )

        size =
            case opts.displaySize of
                Default ->
                    ( "", False )

                Large ->
                    ( "pf-m-display-lg", True )

        className =
            case opts.className of
                Just name ->
                    ( name, True )

                Nothing ->
                    ( "", False )
    in
    [ accordion, isBordered, size, className ]


{-| This function turns a Builder into a HTML component. Put this at
the end of your pipeline to get a useable accordion.

Note - this should be the only Accordion related `toHtml` function you
need to use.
-}
toHtml : Builder msg -> Html msg
toHtml ((Builder opts) as builder) =
    let
        attributes =
            opts.attributes

        component =
            toComponent builder
    in
    component
        (attributes ++ [ classList <| toClasses builder ])
        (List.concatMap (AccordionItem.toHtml << AccordionItem.withHeadingLevel opts.headingLevel) (List.reverse opts.accordionItems))
