module Components.Accordion.Toggle exposing
    ( Builder, default
    , withClassName
    , withComponent
    , withExpanded
    , withAttribute, setAttributes
    , withChild, setChildren
    , withHeadingLevel, toHtml
    )

{-| The toggle of an Accordion Item.


# Builder

@docs Builder, default


# Class name

@docs withClassName


# Component

@docs withComponent


# Expanded

@docs withExpanded


# Attributes

@docs withAttribute, setAttributes


# Children

@docs withChild, setChildren


# Internal

@docs withHeadingLevel, toHtml

-}

import Components.Accordion.Types exposing (HeadingLevel(..))
import Html as H exposing (Attribute, Html, button)
import Html.Attributes exposing (class, classList, type_)
import Icons.AngleRight exposing (angleRight)


{-| Opaque Builder type used to build a pipeline around.
-}
type Builder msg
    = Builder (Options msg)


type alias Options msg =
    { className : Maybe String
    , id : String
    , component :
        List (Attribute msg)
        -> List (Html msg)
        -> Html msg
    , isExpanded : Bool
    , headingLevel : HeadingLevel
    , children : List (Html msg)
    , attributes : List (Attribute msg)
    }


defaultOptions : String -> Options msg
defaultOptions id =
    { className = Nothing
    , id = id
    , component = button
    , isExpanded = False
    , headingLevel = DefinitionList
    , children = []
    , attributes = []
    }


{-| The default accordion builder. This should be the start of a
builder pipeline. An identifier string is required for a toggle.
-}
default : String -> Builder msg
default id =
    Builder <| defaultOptions id



-- * Classname


{-| The accordion content can be given a custom class name by passing in a className
string.
-}
withClassName : String -> Builder msg -> Builder msg
withClassName string (Builder opts) =
    Builder { opts | className = Just string }



-- * Custom component


{-| Component to use as content container.
-}
withComponent : (List (Attribute msg) -> List (Html msg) -> Html msg) -> Builder msg -> Builder msg
withComponent comp (Builder opts) =
    Builder { opts | component = comp }



-- * Is Expanded


{-| Set whether or not the Accordion Toggle is expanded or not. This boolean
should generally be the negation of the Accordion Content's
`withHidden` boolean.
-}
withExpanded : Bool -> Builder msg -> Builder msg
withExpanded bool (Builder opts) =
    Builder { opts | isExpanded = bool }



-- * Heading Level


{-| Change the heading level type of the given Builder. You shouldn't
need to ever call this when making an Accordion - the Accordion's
`toHtml` function will set the heading level of all of it's HTML
elements appropriately.
-}
withHeadingLevel : HeadingLevel -> Builder msg -> Builder msg
withHeadingLevel level (Builder opts) =
    Builder { opts | headingLevel = level }



-- * Children


{-| Add a single child HTML element to the Accordion Toggle's children.
-}
withChild : Html msg -> Builder msg -> Builder msg
withChild html (Builder opts) =
    Builder { opts | children = html :: opts.children }


{-| Give a list of HTML elements and set them as the children of this
Accordion Toggle.
-}
setChildren : List (Html msg) -> Builder msg -> Builder msg
setChildren htmls (Builder opts) =
    Builder { opts | children = htmls }



-- * Attributes


{-| Pass an attribute to the Accordion Content.
-}
withAttribute : Attribute msg -> Builder msg -> Builder msg
withAttribute attr (Builder opts) =
    Builder { opts | attributes = attr :: opts.attributes }


{-| Set the attributes of the Accordion Toggle to be the given list
of attributes.
-}
setAttributes : List (Attribute msg) -> Builder msg -> Builder msg
setAttributes attrs (Builder opts) =
    Builder { opts | attributes = attrs }



-- * To HTML


toClasses : Builder msg -> List ( String, Bool )
toClasses (Builder opts) =
    let
        toggle =
            ( "pf-c-accordion__toggle", True )

        expanded =
            ( "pf-m-expanded", opts.isExpanded )
    in
    [ toggle, expanded ]


toAttributes : List (Attribute msg)
toAttributes =
    [ type_ "button" ]


headingLevelToComponent : HeadingLevel -> List (Html msg) -> Html msg
headingLevelToComponent level =
    case level of
        H1 ->
            H.h1 []

        H2 ->
            H.h2 []

        H3 ->
            H.h3 []

        H4 ->
            H.h4 []

        H5 ->
            H.h5 []

        H6 ->
            H.h6 []

        DefinitionList ->
            H.dt []


{-| This function turns a Builder into a HTML element. This shouldn't
be used if you are constructing an Accordion Builder.
-}
toHtml : Builder msg -> Html msg
toHtml ((Builder opts) as builder) =
    let
        attributes =
            opts.attributes

        component =
            opts.component

        classes =
            classList <| toClasses builder

        attrs =
            toAttributes

        updatedChildren =
            [ H.span [ class "pf-c-accordion__toggle-text" ] opts.children
            , H.span [ class "pf-c-accordion__toggle-icon" ]
                [ angleRight ]
            ]

        wrapper =
            headingLevelToComponent opts.headingLevel
    in
    wrapper [ component (attributes ++ classes :: attrs) updatedChildren ]
